#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

#define BUFF_SIZE 4096
MYSQL_RES *rs_metadata;
// The final config struct will point into this

static char config[BUFF_SIZE];

/**
* JSON type identifier. Basic types are:
* o Object
* o Array
* o String
* o Other primitive: number, boolean (true/false) or null
*/

typedef enum {
    JSMN_UNDEFINED = 0,
    JSMN_OBJECT = 1,
    JSMN_ARRAY = 2,
    JSMN_STRING = 3,
    JSMN_PRIMITIVE = 4
} jsmntype_t;

enum jsmnerr {
    /* Not enough tokens were provided */
    JSMN_ERROR_NOMEM = -1,
    /* Invalid character inside JSON string */
    JSMN_ERROR_INVAL = -2,
    /* The string is not a full JSON packet, more bytes expected */
    JSMN_ERROR_PART = -3
};

/**
* JSON token description.
* type type (object, array, string etc.)
* start start position in JSON data string
* end
end position in JSON data string
*/
typedef struct {
    jsmntype_t type;
    int start;
    int end;
    int size;
} jsmntok_t;


/**
* JSON parser. Contains an array of token blocks available. Also stores
* the string being parsed now and current position in that string
*/
typedef struct {
    unsigned int pos; /* offset in the JSON string */
    unsigned int toknext; /* next token to allocate */
    int toksuper; /* superior token node, e.g parent object or array */
} jsmn_parser;

/**
* Allocates a fresh unused token from the token pool.
*/
static jsmntok_t *jsmn_alloc_token(jsmn_parser *parser, jsmntok_t *tokens, size_t num_tokens) 
{
    jsmntok_t *tok;
    if (parser->toknext >= num_tokens) 
    {
        return NULL;
    }
    tok = &tokens[parser->toknext++];
    tok->start = tok->end = -1;
    tok->size = 0;
    return tok;
}

/**
* Fills token type and boundaries.
*/
static void jsmn_fill_token(jsmntok_t *token, jsmntype_t type,
int start, int end) 
{
    token->type = type;
    token->start = start;
    token->end = end;
    token->size = 0;
}

/**
* Fills next available token with JSON primitive.
*/
static int jsmn_parse_primitive(jsmn_parser *parser, const char *js, size_t len, jsmntok_t *tokens, size_t num_tokens) 
{
    jsmntok_t *token;
    int start;
    start = parser->pos;
    for (; parser->pos < len && js[parser->pos] != '\0'; parser->pos++) {
        switch (js[parser->pos]) {
            /* In strict mode primitive must be followed by "," or "}" or "]" */
            case ':':
            case '\t' : case '\r' : case '\n' : case ' ' :
            case ',' : case ']' : case '}' :
            goto found;
            }
        if (js[parser->pos] < 32 || js[parser->pos] >= 127) {
            parser->pos = start;
            return JSMN_ERROR_INVAL;
        }
    }
    found:
        if (tokens == NULL) {
            parser->pos--;
            return 0;
        }
        token = jsmn_alloc_token(parser, tokens, num_tokens);
        if (token == NULL) {
            parser->pos = start;
            return JSMN_ERROR_NOMEM;
        }
        jsmn_fill_token(token, JSMN_PRIMITIVE, start, parser->pos);
        parser->pos--;
        return 0;
}

/**
* Fills next token with JSON string.
*/

static int jsmn_parse_string(jsmn_parser *parser, const char *js,size_t len, jsmntok_t *tokens, size_t num_tokens) 
{
    jsmntok_t *token;
    int start = parser->pos;
    parser->pos++;
    /* Skip starting quote */
    for (; parser->pos < len && js[parser->pos] != '\0'; parser->pos++) 
    {
        char c = js[parser->pos];
        /* Quote: end of string */
        if (c == '\"') {
            if (tokens == NULL) {
                return 0;
            }
            token = jsmn_alloc_token(parser, tokens, num_tokens);
            if (token == NULL) {
                parser->pos = start;
                return JSMN_ERROR_NOMEM;
            }
            jsmn_fill_token(token, JSMN_STRING, start+1, parser->pos);
            return 0;
        }
        /* Backslash: Quoted symbol expected */
        if (c == '\\' && parser->pos + 1 < len) {
            int i;
            parser->pos++;
            switch (js[parser->pos])
            {
                /* Allowed escaped symbols */
                case '\"': case '/' : case '\\' : case 'b' :
                case 'f' : case 'r' : case 'n' : case 't' :
                    break;
                /* Allows escaped symbol \uXXXX */
                case 'u':
                    parser->pos++;
                    for(i = 0; i < 4 && parser->pos < len && js[parser->pos] != '\0'; i++) {
                        /* If it isn't a hex character we have an error */
                        if(!((js[parser->pos] >= 48 && js[parser->pos] <= 57) || /* 0-9 */
                        (js[parser->pos] >= 65 && js[parser->pos] <= 70) || /* A-F */
                        (js[parser->pos] >= 97 && js[parser->pos] <= 102))) { /* a-f */
                            parser->pos = start;
                            return JSMN_ERROR_INVAL;
                        }
                        parser->pos++;
                    }
                    parser->pos--;
                    break;
                /* Unexpected symbol */
                default:
                    parser->pos = start;
                    return JSMN_ERROR_INVAL;
            }
        }
    }
    parser->pos = start;
    return JSMN_ERROR_PART;
}



/**
* Parse JSON string and fill tokens.
*/
static int jsmn_parse(jsmn_parser *parser, const char *js, size_t len, jsmntok_t *tokens, unsigned int num_tokens) 
{
    int r;
    int i;
    jsmntok_t *token;
    int count = parser->toknext;
    for (; parser->pos < len && js[parser->pos] != '\0'; parser->pos++) {
        char c;
        jsmntype_t type;
        c = js[parser->pos];
        switch (c) {
            case '{': case '[':
                count++;
                if (tokens == NULL) 
                {
                    break;
                }
                token = jsmn_alloc_token(parser, tokens, num_tokens);
                if (token == NULL)
                return JSMN_ERROR_NOMEM;
                if (parser->toksuper != -1) 
                {
                    tokens[parser->toksuper].size++;
                }
                token->type = (c == '{' ? JSMN_OBJECT : JSMN_ARRAY);
                token->start = parser->pos;
                parser->toksuper = parser->toknext - 1;
                break;
            case '}': case ']':
                if (tokens == NULL)
                    break;
                type = (c == '}' ? JSMN_OBJECT : JSMN_ARRAY);
                for (i = parser->toknext - 1; i >= 0; i--) 
                {
                    token = &tokens[i];
                    if (token->start != -1 && token->end == -1) 
                    {
                        if (token->type != type) 
                        {
                            return JSMN_ERROR_INVAL;
                        }
                        parser->toksuper = -1;
                        token->end = parser->pos + 1;
                        break;
                    }
                }
                /* Error if unmatched closing bracket */
                if (i == -1) return JSMN_ERROR_INVAL;
                for (; i >= 0; i--) 
                {
                    token = &tokens[i];
                    if (token->start != -1 && token->end == -1) 
                    {
                        parser->toksuper = i;
                        break;
                    }
                }
                break;
            case '\"':
                r = jsmn_parse_string(parser, js, len, tokens, num_tokens);
                if (r < 0) return r;
                    count++;
                if (parser->toksuper != -1 && tokens != NULL)
                    tokens[parser->toksuper].size++;
                break;
            case '\t' : case '\r' : case '\n' : case ' ':
                break;
            case ':':
                parser->toksuper = parser->toknext - 1;
                break;
            case ',':
                if (tokens != NULL && parser->toksuper != -1 &&
                tokens[parser->toksuper].type != JSMN_ARRAY &&
                tokens[parser->toksuper].type != JSMN_OBJECT) 
                {
                    for (i = parser->toknext - 1; i >= 0; i--) 
                    {
                        if (tokens[i].type == JSMN_ARRAY || tokens[i].type == JSMN_OBJECT) 
                        {
                            if (tokens[i].start != -1 && tokens[i].end == -1) 
                            {
                                parser->toksuper = i;
                                break;
                            }
                        }
                    }
                }
                break;
            /* In non-strict mode every unquoted value is a primitive */
            default:
                r = jsmn_parse_primitive(parser, js, len, tokens, num_tokens);
                if (r < 0) return r;
                    count++;
                if (parser->toksuper != -1 && tokens != NULL)
                    tokens[parser->toksuper].size++;
                break;
        }
    }
    if (tokens != NULL) 
    {
        for (i = parser->toknext - 1; i >= 0; i--) 
        {
            /* Unmatched opened object or array */
            if (tokens[i].start != -1 && tokens[i].end == -1) 
            {
                return JSMN_ERROR_PART;
            }
        }
    }
    return count;
}


/**
* Creates a new parser based over a given buffer with an array of tokens
* available.
*/
static void jsmn_init(jsmn_parser *parser) 
{
    parser->pos = 0;
    parser->toknext = 0;
    parser->toksuper = -1;
}

static int jsoneq(const char *json, jsmntok_t *tok, const char *s)
{
    if (tok->type == JSMN_STRING
    && (int) strlen(s) == tok->end - tok->start
    && strncmp(json + tok->start, s, tok->end - tok->start) == 0) 
    {
        return 0;
    }
    return -1;
}

static size_t load_file(char *filename)
{
    FILE *f = fopen(filename, "rb");
    if(f == NULL) 
    {
        fprintf(stderr, "Unable to open file %s\n", filename);
        exit(1);
    }
    fseek(f, 0, SEEK_END);
    size_t fsize = ftell(f);
    fseek(f, 0, SEEK_SET); //same as rewind(f);
    if(fsize >= BUFF_SIZE) 
    {
        fprintf(stderr, "Configuration file too large\n");
        abort();
    }
    fread(config, fsize, 1, f);
    fclose(f);
    config[fsize] = 0;
    return fsize;
}

int parse_config(char *path, struct configuration *conf)
{
    int i;
    int r;
    jsmn_parser p;
    jsmntok_t t[128]; /* We expect no more than 128 tokens */
    load_file(path);
    jsmn_init(&p);
    r = jsmn_parse(&p, config, strlen(config), t, sizeof(t)/sizeof(t[0]));
    if (r < 0) 
    {
        printf("Failed to parse JSON: %d\n", r);
        return 0;
    }
    /* Assume the top-level element is an object */
    if (r < 1 || t[0].type != JSMN_OBJECT) 
    {
        printf("Object expected\n");
        return 0;
    }
    /* Loop over all keys of the root object */
    for (i = 1; i < r; i++) {
        if (jsoneq(config, &t[i], "host") == 0) 
        {
            /* We may use strndup() to fetch string value */
            conf->host = strndup(config + t[i+1].start, t[i+1].end-t[i+1].start);
            i++;
        } 
        else if (jsoneq(config, &t[i], "username") == 0) 
        {
            conf->db_username = strndup(config + t[i+1].start, t[i+1].end-t[i+1].start);
            i++;
        } 
        else if (jsoneq(config, &t[i], "password") == 0) 
        {
            conf->db_password = strndup(config + t[i+1].start, t[i+1].end-t[i+1].start);
            i++;
        } 
        else if (jsoneq(config, &t[i], "port") == 0) 
        {
            conf->port = strtol(config + t[i+1].start, NULL, 10);
            i++;
        } 
        else if (jsoneq(config, &t[i], "database") == 0) 
        {
            conf->database = strndup(config + t[i+1].start, t[i+1].end-t[i+1].start);
            i++;
        } 
        else 
        {
            printf("Unexpected key: %.*s\n", t[i].end-t[i].start, config + t[i].start);
        }
    }
    return 1;
}


int parse_date(char *date, MYSQL_TIME *parsed)
{
    char d[3];
    char m[3];
    char y[5];
    memcpy(y, date, 4);
    memcpy(m, date+5, 2);
    memcpy(d, date+8, 2);
    y[4]= '\0';
    m[2] = '\0';
    d[2] = '\0';
    parsed->year = atoi(y);
    parsed->month = atoi(m);
    parsed->day = atoi(d);
    return 0;
}

char *parse_time(char *time)
{
    char *parsed = malloc(10);
    memcpy(parsed, time, 5);
    memcpy(parsed+5, ":", 1);
    memcpy(parsed+6, "00\0", 3);
    return parsed;
}

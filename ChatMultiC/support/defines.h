#pragma once

#include <stdbool.h>
#include <mysql/mysql.h>

struct configuration 
{
    char *host;
    char *db_username;
    char *db_password;
    unsigned int port;
    char *database;
    char cf[45];
    char password[45];
};

extern struct configuration conf;
extern int parse_config(char *path, struct configuration *conf);
extern char *getInput(unsigned int lung, char *stringa, bool hide);
extern bool yesOrNo(char *domanda, char yes, char no, bool predef, bool insensitive);
extern char multiChoice(char *domanda, char choices[], int num);
extern bool setup_prepared_stmt(MYSQL_STMT **stmt, char *statement, MYSQL *conn);
extern void run_as_amministratore(MYSQL *conn);
extern void run_as_capoprogetto(MYSQL *conn);
extern void run_as_dipendente(MYSQL *conn);
extern int parse_date(char *date, MYSQL_TIME *parsed);
extern char *parse_time(char *time);

extern MYSQL_RES *rs_metadata;

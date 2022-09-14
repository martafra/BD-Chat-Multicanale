#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
#include "defines.h"


typedef enum 
{
    Amministratore = 1,
    Capoprogetto = 2,
    Dipendente = 3,
    FAILED_LOGIN,
} role_t;

struct configuration conf;
static MYSQL *conn;

static role_t attempt_login(MYSQL *conn, char *cf, char *password) 
{
    MYSQL_STMT *login;
    MYSQL_BIND param[3]; // Used both for input and output
    int role = 0;
    if(!setup_prepared_stmt(&login, "call login(?, ?, ?)", conn)) {
        print_stmt_error(login, "Unable to initialize login statement\n");
        goto err2;
    }
    // Preparazione parametri di input
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
    param[0].buffer = cf;
    param[0].buffer_length = strlen(cf);

    param[1].buffer_type = MYSQL_TYPE_VAR_STRING; // IN
    param[1].buffer = password;
    param[1].buffer_length = strlen(password);
    
    param[2].buffer_type = MYSQL_TYPE_LONG; // OUT
    param[2].buffer = &role;
    param[2].buffer_length = sizeof(role);
    if (mysql_stmt_bind_param(login, param) != 0) { // Note _param
        print_stmt_error(login, "Could not bind parameters for login");
        goto err;
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(login) != 0) {
        print_stmt_error(login, "Could not execute login procedure");
        goto err;
    }
    // Preparazione parametri di output
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_LONG; // OUT
    param[0].buffer = &role;
    param[0].buffer_length = sizeof(role);
    if(mysql_stmt_bind_result(login, param)) {
        print_stmt_error(login, "Could not retrieve output parameter");
        goto err;
    }
    // Recupero parametri di output
    if(mysql_stmt_fetch(login)) {
        print_stmt_error(login, "Could not buffer results");
        goto err;
    }
    mysql_stmt_close(login);
    printf("%d\n", role);
    return role;
    err:
        mysql_stmt_close(login);
    err2:
        return FAILED_LOGIN;
}



int main(void) {
    role_t role;
    if(!parse_config("users/login.json", &conf)) 
    {
        fprintf(stderr, "Unable to load login configuration\n");
        exit(EXIT_FAILURE);
    }
    conn = mysql_init (NULL);
    if (conn == NULL) 
    {
        fprintf (stderr, "mysql_init() failed (probably out of memory)\n");
        exit(EXIT_FAILURE);
    }
    if (mysql_real_connect(conn, conf.host, conf.db_username, conf.db_password, conf.database, conf.port, NULL, CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS) == NULL) 
    {
        fprintf (stderr, "mysql_real_connect() failed\n");
        mysql_close (conn);
        exit(EXIT_FAILURE);
    }

    else
    {
        printf("Codice fiscale: ");
        getInput(45, conf.cf, false);
        printf("Password: ");
        getInput(45, conf.password, true);
        role = attempt_login(conn, conf.cf, conf.password);
    }
    switch(role) {
        case Amministratore:
            run_as_amministratore(conn);
            break;
        case Capoprogetto:
            run_as_capoprogetto(conn);
            break;
        case Dipendente:
            run_as_dipendente(conn);
            break;
        case FAILED_LOGIN:
            fprintf(stderr, "Le credenziali inserite non corrispondono a nessun utente presente nel sistema\n");
            exit(EXIT_FAILURE);
            break;
        default:
            fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
            abort();
    }
    printf("Arrivederci!\n");
    mysql_close (conn);
    return 0;
}

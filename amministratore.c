#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
#include "defines.h"


// funzione da chiamare in caso di inserimento di un progetto
static void inserisci_progetto(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    char nomeprogetto[45];
    char options[2] = {'1','2'};
    char op1;
  
    // retrieve del parametro necessario (titolo)
    printf("\nDigitare il nome da associare al progetto: ");
    getInput(45, nomeprogetto, false);


    MYSQL_BIND param[1];
    if(!setup_prepared_stmt(&prepared_stmt, "call insert_progetto( ? )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile inserire il progetto\n", false);
    }
    // Preparazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = nomeprogetto;
    param[0].buffer_length = strlen(nomeprogetto);

    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri per l'inserimento del progetto\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nell'inserimento del progetto.");
        mysql_stmt_close(prepared_stmt);
    } 
    else 
    {
        printf("Progetto inserito correttamente...\n");
        mysql_stmt_close(prepared_stmt);


        printf("\nVuoi inserire un altro progetto? \n1) Sì \n2) No\n");
        op1 = multiChoice("Select: ", options, 2);
        switch(op1)
        {
            case '1':
                inserisci_progetto(conn);
                break;
            case '2':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
    }
}

// funzione in grado di stampare lista progetti + canali di comunicazione
static void stampa_progetti(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    char op1;
    char header[512];
    char options[4] = {'1','2','3','4'};
    int results;
  
    if(!setup_prepared_stmt(&prepared_stmt, "call retrieve_progetti_canali( )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile stampare la lista dei progetti\n", false);
    }


    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nella stampa della lista dei progetti.");
        goto out;
    } 

    
        dump_result_set(conn, prepared_stmt, header, &results);
        
        out:
        mysql_stmt_close(prepared_stmt);


        printf("*** Azioni disponibili: ***\n\n");
        printf("1) Assegnare coordinazione progetto ad un capoprogetto\n");
        printf("2) Chiusura di un progetto\n");
        printf("3) Consultare un canale di comunicazione\n");
        printf("4) Chiudere l'applicazione\n");
        op1 = multiChoice("Select: ", options, 4);
        switch(op1)
        {
            case '1':
                inserisci_coordinazione_progetto(conn);
                break;
            case '2':
                inserisci_chiusura_progetto(conn);
                break;
            case '3':
                consultazione_canale(conn);
                break;   
            case '4':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
    
}

//funzione da chiamare in caso in cui si voglia affidare un progetto ad un capoprogetto
static void inserisci_coordinazione_progetto(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    MYSQL_BIND param[2];
    char option[2] = {'1','2'};
    char op1;
    // Parametri necessari alla relazione di coordinazione
    char cf[45];
    char id_c[45];
    int id;
    int tratta;
    // Retrieve informazioni
    printf("\nInserire codice fiscale capoprogetto: ");
        getInput(45, cf, false);
        

    printf("Inserire ID del progetto: ");
    while(true)
    {
        getInput(45, id_c, false);
        if(int_compare(id_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    id = atoi(id_c);
    // stored procedure call
    if(!setup_prepared_stmt(&prepared_stmt, "call coordinazione_progetto(?, ?)", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile assegnare coordinazione progetto\n", false);
    }
    // sistemazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = cf;
    param[0].buffer_length = strlen(cf);
    param[1].buffer_type = MYSQL_TYPE_LONG;
    param[1].buffer = &id;
    param[1].buffer_length = sizeof(id);
    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Non è stato possibile effettuare il bind dei parametri\n" , true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error(prepared_stmt, "Errore nell'assegnazione del progetto al manager.");
        goto out;
    }
    printf("Coordinazione progetto assegnata correttamente...\n");
    out:
    {mysql_stmt_close(prepared_stmt);}
    
    printf("\nVuoi gestire la coordinazione di un altro progetto? \n1) Sì \n2) No\n");
        op = multiChoice("Select: ", option, 2);
        switch(op)
        {
            case '1':
                inserisci_coordinazione_progetto(conn);
                break;
            case '2':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
}

static void inserisci_chiusura_progetto(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    MYSQL_BIND param[2];
    // parametri necessari all'operazione di chiusura del progetto
    char id_c[45];
    int id;
    char data_c[11];
    char options[2] = {'1','2'};
    char op;
    MYSQL_TIME data;
    // retrieve informazioni
    printf("\nInserire ID del progetto che si vuole chiudere: ");
    getInput(45, id_c, false);
    id = atoi(id_c);
    printf("Data chiusura(yyyy-mm-dd): ");
    while(true){
        getInput(11, data_c, false);
        if(date_compare(data_c)) break;
        else printf("Formato errato, riprova: ");
    }

    parse_date(data_c, &data);
    // Prepare stored procedure call
    if(!setup_prepared_stmt(&prepared_stmt, "call chiusura_progetto(?, ?)", conn)) {
        finish_with_stmt_error(conn, prepared_stmt, "Non è stato possibile effettuare la chiusura del progetto\n", false);
    }
    // sistemazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_LONG;
    param[0].buffer = id;
    param[0].buffer_length = sizeof(id);
    param[1].buffer_type = MYSQL_TYPE_DATE;
    param[1].buffer = &data;
    param[1].buffer_length = sizeof(MYSQL_TIME);
    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
    finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) {
        print_stmt_error (prepared_stmt, "Errore nella chiusura del progetto.");
    } else {
        printf("Progetto chiuso correttamente...\n");
    }
    mysql_stmt_close(prepared_stmt);
    printf("\nVuoi gestire la coordinazione di un altro progetto? \n1) Sì \n2) No\n");
        op = multiChoice("Select: ", options, 2);
        switch(op)
        {
            case '1':
                inserisci_chiusura_progetto(conn);
                break;
            case '2':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
}

static void consultazione_canale{
    MYSQL_STMT *prepared_stmt;
    char header[512];
    char options[4] = {'1','2','3','4'};
    int results;
    //parametri necessari
    char id_c[45];
    char cod_c[45];
    int id;
    int cod;
    // Retrieve informazioni
    printf("Inserire ID del progetto: ");
    while(true)
    {
        getInput(45, id_c, false);
        if(int_compare(id_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    id = atoi(id_c);
    printf("Inserire codice del canale: ");
    while(true)
    {
        getInput(45, cod_c, false);
        if(int_compare(cod_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    cod = atoi(cod_c);
    // sistemazione parametri
    param[0].buffer_type = MYSQL_TYPE_LONG;
    param[0].buffer = cod;
    param[0].buffer_length = sizeof(cod);
    param[1].buffer_type = MYSQL_TYPE_LONG;
    param[1].buffer = id;
    param[1].buffer_length = sizeof(id);  
    // chiamata procedura
    if(!setup_prepared_stmt(&prepared_stmt, "call retrieve_conversazioni( ?, ? )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile stampare le conversazioni\n", false);
    }
    
    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri\n", true);
    }


    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nella stampa delle conversazioni.");
        mysql_stmt_close(prepared_stmt);
	return;
    } 

    	// stampa conversazioni
        dump_result_set(conn, prepared_stmt, header, &results);
        mysql_stmt_close(prepared_stmt);
	return;
    
}


static void inserisci_lavoratore(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    MYSQL_BIND param[54;
    char option[2] = {'1', '2'};
    char op;
    // Parametri necessari all'inserimento
    char cf[45];
    char nome[45];
    char cognome[45];
    unsigned char char_ruolo;

    // Retrieve informazioni da input utente
    printf("\nCodice fiscale lavoratore: ");
    getInput(45, cf, false);
    printf("Nome lavoratore: ");
    getInput(45, nome, false);
    printf("Cognome lavoratore: ");
    getInput(45, cognome, false);
    printf("Inserire un ruolo:\n1)Capoprogetto\n2)Dipendente\n");
    char_ruolo=multiChoice("Select:", option, 2);
    if (char_ruolo != '1' || char_ruolo != '2') 
    {
        printf("L'opzione inserita non è valida\n");
        abort();
    }
    // Preparazione stored procedure
    if(!setup_prepared_stmt(&prepared_stmt, "call insert_lavoratore(?, ?, ?, ?)", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile inizializzare l'inserimento di un Lavoratore\n", false);
    }
    // sistemazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = cf;
    param[0].buffer_length = strlen(cf);
    param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[1].buffer = nome;
    param[1].buffer_length = strlen(name);
    param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[2].buffer = cognome;
    param[2].buffer_length = strlen(surname);
    param[3].buffer_type = MYSQL_TYPE_TINY;
    param[3].buffer = ruolo;
    param[3].buffer_length= strlen(ruolo);

    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri perl'inserimento di un lavoratore\n", true);
    }
 
    if (mysql_stmt_execute(prepared_stmt) != 0) {
        print_stmt_error(prepared_stmt, "Errore durante l'inserimento del lavoratore.");
        goto out;
    }
    printf("Lavoratore inserito correttamente...\n");
    out:
        {mysql_stmt_close(prepared_stmt);}
    printf("\nVuoi inserire un altro lavoratore? \n1) Sì \n2) No\n");
        op = multiChoice("Select: ", option, 2);
        switch(op)
        {
            case '1':
                inserisci_lavoratore(conn);
                break;
            case '2':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
}


static void inserisci_utente(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    MYSQL_BIND param[3];
    char options[3] = {'1','2', '3'};
    char r;
    char op1;

    char cf[45];
    char password[45];
    char ruolo[45];
    // Get the required information
    printf("\nCodice fiscale: ");
    getInput(45, cf, false);
    printf("Password: ");
    getInput(45, password, true);
    printf("Assegnare uno tra i ruoli disponibili:\n");
    printf("\t1) Amministratore\n");
    printf("\t2) Capoprogetto\n");
    printf("\t3) Dipendente\n");

    r = multiChoice("Select role", options, 3);
    // Converte ruolo nel valore corrispondente
    switch(r) {
        case '1':
            strcpy(ruolo, "Amministratore");
            break;
        case '2':
            strcpy(ruolo, "Capoprogetto");
            break;
        case '3':
            strcpy(ruolo, "Dipendente");
            break;
        default:
            fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
            abort();
    }
    // Preparazione chiamata store procedure
    if(!setup_prepared_stmt(&prepared_stmt, "call insert_utente(?, ?, ?)", conn)) {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile inizializzare l'inserimento dell'utente\n", false);
    }
    // Prepare parameters
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = cf;
    param[0].buffer_length = strlen(username);
    param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[1].buffer = password;
    param[1].buffer_length = strlen(password);
    param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[2].buffer = ruolo;
    param[2].buffer_length = strlen(ruolo);
    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) {
        finish_with_stmt_error(conn, prepared_stmt, "Non è stato possibile effettuare il bind dei parametri per l'inserimento dell'utente\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nell'inserimento dell'utente.");
    } 
    else 
    {
        printf("Utente inserito correttamente...\n");
    }
    mysql_stmt_close(prepared_stmt);
        
        printf("\nVuoi inserire un altro utente? \n1) Sì \n2) No\n");
        op1 = multiChoice("Select: ", options, 2);
        switch(op1)
        {
            case '1':
                inserisci_utente(conn);
                break;
            case '2':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        
    
    
}


void run_as_amministratore(MYSQL *conn)
{
    char options[5] = {'1','2', '3', '4', '5'};
    char op;
    printf("Benvenuto amministratore.\n");
    if(!parse_config("users/amministratore.json", &conf)) {
        fprintf(stderr, "Non è stato possibile attivare la modalità d'uso prevista!\n");
        exit(EXIT_FAILURE);
    }
    if(mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
        fprintf(stderr, "mysql_change_user() failed\n");
        exit(EXIT_FAILURE);
    }
    while(true) {
        printf("\033[2J\033[H");
        printf("*** Azioni disponibili: ***\n\n");
        printf("1) Inserire un nuovo progetto\n");
        printf("2) Inserire un nuovo lavoratore\n");
        printf("3) Inserire un nuovo utente\n");
        printf("4) Gestire informazioni riguardanti progetti esistenti\n");
        printf("5) Chiudere l'applicazione\n");
        op = multiChoice("Select an option", options, 5);
        switch(op) {
            case '1':
                inserisci_progetto(conn);
                break;
            case '2':
                inserisci_lavoratore(conn);
                break;
            case '3':
                inserisci_utente(conn);
                break;
            case '4':
            	stampa_progetti(conn);
            	break;
            case '5':
                return;
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
        getchar();
    }
},

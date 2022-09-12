#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "utils.h"
#include "defines.h"

static void inserisci_canale_di_comunicazione(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt;
    char options[2] = {'1','2'}
    char op1;
    // parametri necessari all'inserimento del canale
    char nomecanale[45];
    char id_c;
    int id;
    // retrieve dei parametri necessari
    printf("Inserire ID del progetto associato: ");
    while(true)
    {
        getInput(45, id_c, false);
        if(int_compare(id_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    id = atoi(id_c);
    printf("\nInserire il nome da associare al canale: ");
    getInput(45, nomecanale, false);


    MYSQL_BIND param[3];
    if(!setup_prepared_stmt(&prepared_stmt, "call creazione_canale( ?, ?, ? )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile inserire il canale di comunicazione\n", false);
    }
    // Preparazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_LONG;
    param[0].buffer = id;
    param[0].buffer_length = sizeof(id);
    param[1].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[1].buffer = nomecanale;
    param[1].buffer_length = strlen(nomecanale);
    param[2].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[2].buffer = conf.cf;
    param[2].buffer_length = strlen(conf.cf);

    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nell'inserimento del canale di comunicazione.");
        mysql_stmt_close(prepared_stmt);
    } 
    else 
    {
        printf("Canale di comunicazione inserito correttamente...\n");
        mysql_stmt_close(prepared_stmt);


        printf("\nVuoi inserire un altro canale di comunicazione? \n1) Sì \n2) No\n");
        op1 = multiChoice("Select: ", options, 2);
        switch(op1)
        {
            case '1':
                inserisci_canale_di_comunicazione(conn);
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



static void inserisci_appartenenza_canale(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt0;
    char options[2] = {'1','2'}
    char op1;
    int results0;
    char header0[512];
    // fase di lettura
    if(!setup_prepared_stmt(&prepared_stmt0, "call retrieve_appartenenza_coordinazione(?)", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt0, "Impossibile stampare la lista dei progetti\n", false);
    }
    // sistemazione parametri
    MYSQL_BIND param0[1];
    memset(param0, 0, sizeof(param0));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = conf.cf;
    param[0].buffer_length = strlen(conf.cf);
    if (mysql_stmt_bind_param(prepared_stmt0, param0) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt0, "Non è stato possibile effettuare il bind dei parametri\n" , true);
    }

    if (mysql_stmt_execute(prepared_stmt0) != 0) 
    {
        print_stmt_error (prepared_stmt0, "Errore nella stampa della lista dei progetti.");
        goto out;
    } 

    
        dump_result_set(conn, prepared_stmt0, header0, &results0);
        
        out:
        mysql_stmt_close(prepared_stmt0);

    //fase di inserimento
    MYSQL_STMT *prepared_stmt;
    // parametri necessari 
    char cf[45];
    char id_c;
    int id;
    char cod_c;
    int cod;
    // retrieve dei parametri necessari
    printf("Inserire codice del canale di interesse: ");
    while(true)
    {
        getInput(45, cod_c, false);
        if(int_compare(cod_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    cod = atoi(cod_c);
    printf("Inserire ID del progetto associato: ");
    while(true)
    {
        getInput(45, id_c, false);
        if(int_compare(id_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    id = atoi(id_c);
    printf("\nInserire il codice fiscale del dipendente: ");
    getInput(45, cf, false);


    MYSQL_BIND param[3];
    if(!setup_prepared_stmt(&prepared_stmt, "call assegnazione_canale( ?, ?, ? )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile invitare il dipendente nel canale\n", false);
    }
    // Preparazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = cf;
    param[0].buffer_length = strlen(cf);
    param[1].buffer_type = MYSQL_TYPE_LONG;
    param[1].buffer = cod;
    param[1].buffer_length = sizeof(cod);
    param[2].buffer_type = MYSQL_TYPE_VAR_LONG;
    param[2].buffer = id;
    param[2].buffer_length = sizeof(id);

    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nell'inserimento del dipendente nel canale.");
        mysql_stmt_close(prepared_stmt);
    } 
    else 
    {
        printf("Dipendente inserito correttamente...\n");
        mysql_stmt_close(prepared_stmt);


        printf("\nVuoi inserire un altro dipendente in un canale di comunicazione? \n1) Sì \n2) No\n");
        op1 = multiChoice("Select: ", options, 2);
        switch(op1)
        {
            case '1':
                inserisci_appartenenza_canale(conn);
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

static void inserisci_assegnazione_progetto(MYSQL *conn)
{
    MYSQL_STMT *prepared_stmt0;
    char options[2] = {'1','2'}
    char op1;
    int results0;
    char header0[512];
    // prima fase di lettura
    if(!setup_prepared_stmt(&prepared_stmt0, "call retrieve_appartenenza_coordinazione(?)", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt0, "Impossibile stampare la lista dei progetti\n", false);
    }
    // sistemazione parametri
    MYSQL_BIND param0[1];
    memset(param0, 0, sizeof(param0));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = conf.cf;
    param[0].buffer_length = strlen(conf.cf);
    if (mysql_stmt_bind_param(prepared_stmt0, param0) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt0, "Non è stato possibile effettuare il bind dei parametri\n" , true);
    }

    if (mysql_stmt_execute(prepared_stmt0) != 0) 
    {
        print_stmt_error (prepared_stmt0, "Errore nella stampa della lista dei progetti.");
        goto out;
    } 

    
        dump_result_set(conn, prepared_stmt0, header0, &results0);
        
        out:
        mysql_stmt_close(prepared_stmt0);
    // seconda fase di lettura    
    int results1;
    char header1[512];
    if(!setup_prepared_stmt(&prepared_stmt1, "call retrieve_dipendenti()", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt1, "Impossibile stampare la lista dei dipendenti\n", false);
    }
    /* sistemazione parametri
    MYSQL_BIND param1[1];
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = conf.cf;
    param[0].buffer_length = strlen(conf.cf);
    if (mysql_stmt_bind_param(prepared_stmt1, param1) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt1, "Non è stato possibile effettuare il bind dei parametri\n" , true);
    }*/

    if (mysql_stmt_execute(prepared_stmt1) != 0) 
    {
        print_stmt_error (prepared_stmt1, "Errore nella stampa della lista dei dipendenti.");
        goto out1;
    } 

    
        dump_result_set(conn, prepared_stmt1, header1, &results1);
        
        out:1
        mysql_stmt_close(prepared_stmt1);

    //fase di inserimento
    MYSQL_STMT *prepared_stmt;
    // parametri necessari 
    char cf[45];
    char id_c;
    int id;

    // retrieve dei parametri necessari
    printf("Inserire ID del progetto associato: ");
    while(true)
    {
        getInput(45, id_c, false);
        if(int_compare(id_c)) 
        break;
        else printf("Formato errato, riprova: ");
    }
    id = atoi(id_c);
    printf("\nInserire il codice fiscale del dipendente: ");
    getInput(45, cf, false);

    MYSQL_BIND param[2];
    if(!setup_prepared_stmt(&prepared_stmt, "call assegnazione_progetto( ?, ? )", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile assegnare il progetto al dipendente\n", false);
    }
    // Preparazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = cf;
    param[0].buffer_length = strlen(cf);
    param[1].buffer_type = MYSQL_TYPE_VAR_LONG;
    param[1].buffer = id;
    param[1].buffer_length = sizeof(id);

    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile effettuare il bind dei parametri\n", true);
    }
    // Esecuzione procedura
    if (mysql_stmt_execute(prepared_stmt) != 0) 
    {
        print_stmt_error (prepared_stmt, "Errore nell'assegnazione del progetto al dipendente.");
        mysql_stmt_close(prepared_stmt);
    } 
    else 
    {
        printf("Dipendente inserito correttamente...\n");
        mysql_stmt_close(prepared_stmt);


        printf("\nVuoi assegnare un progetto ad un dipendente? \n1) Sì \n2) No\n");
        op1 = multiChoice("Select: ", options, 2);
        switch(op1)
        {
            case '1':
                inserisci_assegnazione_progetto(conn);
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




static void stampa_progetti_coordinazione(*MYSQL conn){
    MYSQL_STMT *prepared_stmt;
    MYSQL_BIND param[1];
    char op1;
    char header[512];
    char options[5] = {'1','2','3','4','5'};
    int results;
  
    if(!setup_prepared_stmt(&prepared_stmt, "call retrieve_coordinazione(?)", conn)) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Impossibile stampare la lista dei progetti\n", false);
    }
    
    // sistemazione parametri
    memset(param, 0, sizeof(param));
    param[0].buffer_type = MYSQL_TYPE_VAR_STRING;
    param[0].buffer = conf.cf;
    param[0].buffer_length = strlen(conf.cf);
    if (mysql_stmt_bind_param(prepared_stmt, param) != 0) 
    {
        finish_with_stmt_error(conn, prepared_stmt, "Non è stato possibile effettuare il bind dei parametri\n" , true);
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
        printf("1) Creare un canale di comunicazione afferente ad un progetto\n");
        printf("2) Aggiungere un dipendente ad un canale di comunicazione\n");
        printf("3) Consultare un canale di comunicazione\n");
	printf("4) Assegnare un progetto ad un dipendente\n");
        printf("5) Chiudere l'applicazione\n");
        op1 = multiChoice("Select: ", options, 4);
        switch(op1)
        {
            case '1':
                inserisci_canale_di_comunicazione(conn);
                break;
            case '2':
                inserisci_appartenenza_canale(conn);
                break;
            case '3':
                consultazione_canale();
                break;   
            case '4':
                inserisci_assegnazione_progetto(conn);
                break; 
            case '5':
                printf("\nArrivederci!");
                return;
        
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }

}



void run_as_capoprogetto(MYSQL *conn)
{
    char options[3] = {'1','2','3'};
    char op;
    printf("Benvenuto capoprogetto!\n");
    if(!parse_config("users/capoprogetto.json", &conf)) {
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
        printf("1) Attività di coordinazione sui progetti\n");
	printf("2) Attività di messaggistica legate ai progetti\n");
        printf("3) Chiudere l'applicazione\n");
        op = multiChoice("Select an option", options, 3);
        switch(op) {
            case '1':
                stampa_progetti_coordinazione(conn);
                break;
            case '3':
            	stampa_progetti_messaggistica(conn);
                return;
            default:
                fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
                abort();
        }
        getchar();
    }
}

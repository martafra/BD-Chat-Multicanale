
#include <stdbool.h>
#include <mysql/mysql.h>

extern void print_error (MYSQL *conn, char *message);
extern void print_stmt_error (MYSQL_STMT *stmt, char *message);
extern void finish_with_stmt_error(MYSQL *conn, MYSQL_STMT *stmt, char *message, bool close_stmt);
extern void dump_result_set(MYSQL *conn, MYSQL_STMT *stmt, char *title, int *num_result);
extern int date_compare(char *s);
extern int time_compare(char *s);
extern int int_compare(char *s);

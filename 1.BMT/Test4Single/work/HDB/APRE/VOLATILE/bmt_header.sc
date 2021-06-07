#include <assert.h>
#include <limits.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#define ASSERT_SQL                                                      \
    if ( sqlca.sqlcode != SQL_SUCCESS ) {                               \
        printf( "Error : [%d] %s\n", SQLCODE, sqlca.sqlerrm.sqlerrmc ); \
        abort();                                                        \
    }

typedef struct threadContext {
    pthread_mutex_t connected;
    char            connection[1024];
    int             minimum;
    int             maximum;
    long long       sum;
    int             numberOfTransactions;
    int             numberOfLongTransactions;
} threadContext;

int numberOfThreads;
int startValue;
int numberOfTransactions;
int sizeOfUnit;
int threshold;
int cap;

struct timeval connectTime;
struct timeval startTime;
struct timeval endTime;

pthread_mutex_t* mutex;
int*             remain;
int*             cursor;
int*             allocated;

EXEC SQL BEGIN DECLARE SECTION;
char user[1024];
char password[1024];
char option[1024];
char test_mode[1024];
EXEC SQL END DECLARE SECTION;

int compareThreadContexts ( const void* element1, const void* element2 ) {
    
    const threadContext* context1;
    const threadContext* context2;
    
    context1 = (const threadContext*)element1;
    context2 = (const threadContext*)element2;
    
    if ( context1->numberOfTransactions < context2->numberOfTransactions ) return -1;
    if ( context1->numberOfTransactions > context2->numberOfTransactions ) return  1;
    
    return 0;
    
}

int allocateUnit ( int* start, int* end ) {
    
    int size;
    int elapsed;
    
    assert( pthread_mutex_lock( mutex ) == 0 );
    
    if ( cap > 0 ) {
        assert( gettimeofday( &endTime, NULL ) == 0 );
        if ( endTime.tv_usec > startTime.tv_usec ) {
            elapsed = ( endTime.tv_sec  - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec - startTime.tv_usec );
        } else {
            elapsed = ( endTime.tv_sec  - 1 - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec + 1000000 - startTime.tv_usec );
        }
        while ( (double)(*allocated) / ( (double)elapsed / 1000000. ) > (double)cap ) {
            sched_yield();
            assert( gettimeofday( &endTime, NULL ) == 0 );
            if ( endTime.tv_usec > startTime.tv_usec ) {
                elapsed = ( endTime.tv_sec  - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec - startTime.tv_usec );
            } else {
                elapsed = ( endTime.tv_sec  - 1 - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec + 1000000 - startTime.tv_usec );
            }
        }
    }
    
    if ( (*remain) > sizeOfUnit ) {
        size       = sizeOfUnit;
        (*remain) -= sizeOfUnit;
    } else {
        size       = (*remain);
        (*remain) -= (*remain);
    }
    *start        = (*cursor);
    *end          = (*cursor) + size;
    (*cursor)    += size;
    (*allocated) += size;
    
    assert( pthread_mutex_unlock( mutex ) == 0 );
    
    return size;
      
}

char* workingDirectory() {
    
    static char buffer[4096];
    
    char* directory;
    char* home;
    
    directory = getcwd( buffer, sizeof(buffer) - 1 );
    home      = getenv( "STANDARD_WORK" );
    
    assert( directory != NULL );
    if ( home != NULL ) {
        if ( strncmp( directory, home, strlen( home ) ) == 0 ) {
            directory += strlen( home );
        }
    }
    while( *directory == '/' || *directory == '\\' ) {
        directory++;
    }
    
    return directory;
        
}
void writeResult( char* mode, int dimension, int axis1, double axis2, double LongTransaction, int minimum, int maximum, int average ) {

    char* result;
    char* date;
    char* host;
    char* revision;
    char  filename[4096];
    FILE* file;
    char* interface;
    char* totalthread;
    char* product;
    char* unit;
    char* name;

    result = getenv( "STANDARD_RESULT" );

    if ( result != NULL ) {

        date = getenv( "STANDARD_DATE" );
        if ( date == NULL ) {
            date = "YYYYMMDD";
        }
        interface = getenv( "STANDARD_INTERFACE" );
        if ( interface == NULL ){
            interface = "unknown";
        }
        host = getenv( "STANDARD_HOST" );
        if ( host == NULL ) {
            host = "NOHOST";
        }
        totalthread = getenv( "STANDARD_ALLTHREAD" );
        if ( totalthread == NULL ) {
            totalthread = "0";
        }
        
        revision = getenv( "STANDARD_REVISION" );
        if ( revision == NULL ){
            revision = "unknown";
        }
        product = getenv( "STANDARD_PRODUCT" );
        if ( product == NULL ){
            product = "unknown";
        }
        unit = "TPS";
        name = "STANDARDBMT";

        sprintf( filename, "%s/%s_HDB-APRE_%s.sql", result, host, date );
        file = fopen( filename, "a" );
        assert( file != NULL );

        switch ( dimension ) {
         case 1:
            break;
         case 2:
            fprintf( file, "%s, %s, %s, %s, %s, %s, %s, %s, %d, %s, %.2f, %.2f, %d, %d, %d \n", date, host, product, revision, name, mode, interface, totalthread, axis1, unit, axis2, LongTransaction, minimum, maximum, average );
            break;
         default:
            assert( dimension == 1 || dimension == 2 ) ;
            break;
        }

        assert( fclose( file ) == 0 );

    }
}


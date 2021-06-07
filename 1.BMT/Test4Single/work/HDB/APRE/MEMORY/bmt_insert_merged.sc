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
void* worker ( void* argument ) {
    
    EXEC SQL BEGIN DECLARE SECTION;
    char   connection[1024];
    int    k01;
    char   k02[12];
    char   k03[12];
    char   k04[11];
    char   k05[11];
    char   k06[11];
    char   k07[21];
    char   k08[21];
    char   k09[21];
    char   k10[21];
    double k11;
    double k12;
    double k13;
    char   k14[11];
    char   k15[51];
    char   k16[51];
    char   k17[51];
    char   k18[51];
    int    k19;
    int    k20;
    char   k21[4];
    char   k22[4];
    char   k23[11];
    int    k24;
    int    k25;
    int    k26;
    int    k27;
    char   k28[31];  
    char   k29[31];  
    char   k30[31];  
    char   k31[12];
    double k32;
    double k33;
    int    k34;
    int    k35;
    char   k36[11];
    char   k37[11];
    char   k38[101];  
    char   k39[101];  
    char   k40[101];  
    int    k41;
    int    k42;
    int    k43;
    double k44;
    double k45;
    char   k46[11];
    char   k47[11];
    char   k48[12];
    char   k49[12];
    char   k50[21];
    char   k51[12];
    int    k52;
    int    k53;
    char   k54[12];
    char   k55[21];
    char   k56[21];
    char   k57[21];
    double k58;
    int    k59;
    char   k60[301];
    EXEC SQL END DECLARE SECTION;
    
    int            start;
    int            end;
    int            value;
    double	   dvalue;
    struct timeval startTime;
    struct timeval endTime;
    int            elapsed;

    dvalue = 12345.67809;
    
    k11 = dvalue;
    k12 = dvalue;
    k13 = dvalue;
    k32 = dvalue;
    k33 = dvalue;
    k44 = dvalue;
    k45 = dvalue;
    k58 = dvalue;

    memset( k02, 0, sizeof(k02) );
    memset( k03, 0, sizeof(k03) );
    memset( k04, 0, sizeof(k04) );
    memset( k05, 0, sizeof(k05) );
    memset( k06, 0, sizeof(k06) );
    memset( k07, 0, sizeof(k07) );
    memset( k08, 0, sizeof(k08) );
    memset( k09, 0, sizeof(k09) );
    memset( k10, 0, sizeof(k10) );
    memset( k14, 0, sizeof(k14) );
    memset( k15, 0, sizeof(k15) );
    memset( k16, 0, sizeof(k16) );
    memset( k17, 0, sizeof(k17) );
    memset( k18, 0, sizeof(k18) );
    memset( k21, 0, sizeof(k21) );
    memset( k22, 0, sizeof(k22) );
    memset( k23, 0, sizeof(k23) );
    memset( k28, 0, sizeof(k28) );
    memset( k29, 0, sizeof(k29) );
    memset( k30, 0, sizeof(k30) );
    memset( k31, 0, sizeof(k31) );
    memset( k36, 0, sizeof(k36) );
    memset( k37, 0, sizeof(k37) );
    memset( k38, 0, sizeof(k38) );
    memset( k39, 0, sizeof(k39) );
    memset( k40, 0, sizeof(k40) );
    memset( k46, 0, sizeof(k46) );
    memset( k47, 0, sizeof(k47) );
    memset( k48, 0, sizeof(k48) );
    memset( k49, 0, sizeof(k49) );
    memset( k50, 0, sizeof(k50) );
    memset( k51, 0, sizeof(k51) );
    memset( k54, 0, sizeof(k54) );
    memset( k55, 0, sizeof(k55) );
    memset( k56, 0, sizeof(k56) );
    memset( k57, 0, sizeof(k57) );
    memset( k60, 0, sizeof(k60) );
    strcpy( k02, "22-DEC-2014" );
    strcpy( k03, "22-DEC-2014" );
    strcpy( k04, "abcdefghij" );
    strcpy( k05, "abcdefghij" );
    strcpy( k06, "abcdefghij" );
    strcpy( k07, "abcdefghijklmnopq" );
    strcpy( k08, "abcdefghijklmnopqr" );
    strcpy( k09, "abcdefghijklmnopqrs" );
    strcpy( k10, "abcdefghijklmnopqrst" );
    strcpy( k14, "abcdefghij" );
    strcpy( k15, "abcdefghijklmnopqrst          abcdefghijklmnopqrst" );
    strcpy( k16, "abcdefghijklmnopqrst     abcdefghijklmnopqrst" );
    strcpy( k17, "     abcdefghijklmnopqrst     abcdefghijklmnopqrst" );
    strcpy( k18, " abcdefghijklmnopqrst        abcdefghijklmnopqrst " );
    strcpy( k21, "abs" );
    strcpy( k22, "xyz" );
    strcpy( k23, "abcdefghij" );
    strcpy( k28, "abcdefghijklmnopqrstuvwxyz0123" );
    strcpy( k29, "abcdefghijklmnopqrstuvwxyz0123" );
    strcpy( k30, "abcdefghijklmnopqrstuvwxyz0123" );
    strcpy( k31, "22-DEC-2014" );
    strcpy( k36, "abcdefghij" );
    strcpy( k37, "abcdefghij" );
    strcpy( k38, "abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz01230123456789" );
    strcpy( k39, "abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz01230123456789" );
    strcpy( k40, "abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz0123abcdefghijklmnopqrstuvwxyz01230123456789" );
    strcpy( k46, "abcdefghij" );
    strcpy( k47, "abcdefghij" );
    strcpy( k48, "22-DEC-2014" );
    strcpy( k49, "22-DEC-2014" );
    strcpy( k50, "abcdefghijklmnopqrst" );
    strcpy( k51, "22-DEC-2014" );
    strcpy( k54, "22-DEC-2014" );
    strcpy( k55, "abcdefghijklmnopqrst" );
    strcpy( k56, "abcdefghijklmnopqrst" );
    strcpy( k57, "abcdefghijklmnopqrst" );
    strcpy( k60, "abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz1234567890okOK" );
    
    threadContext* context = (threadContext*)argument;
    
    strcpy( connection, context->connection );
    
    EXEC SQL AT :connection CONNECT :user IDENTIFIED BY :password USING :option;
    ASSERT_SQL;
    
    assert( pthread_mutex_unlock( &(context->connected) ) == 0 );
    
    while ( allocateUnit( &start, &end ) > 0 ) {
        
        for ( value = start; value < end; value++ ) {
            
            assert( gettimeofday( &startTime, NULL ) == 0 );

            k01 = value;
            k19 = value;
            k20 = value;
            k24 = value;
            k25 = value;
            k26 = value;
            k27 = value;
            k34 = value;
            k35 = value;
            k41 = value;
            k42 = value;
            k43 = value;
            k52 = value;
            k53 = value;
            k59 = value;
            
            EXEC SQL AT :connection INSERT INTO TEST
                                       VALUES ( :k01, :k02, :k03, :k04, :k05, :k06, :k07, :k08, :k09, :k10, 
                                                :k11, :k12, :k13, :k14, :k15, :k16, :k17, :k18, :k19, :k20,
                                                :k21, :k22, :k23, :k24, :k25, :k26, :k27, :k28, :k29, :k30, 
                                                :k31, :k32, :k33, :k34, :k35, :k36, :k37, :k38, :k39, :k40, 
                                                :k41, :k42, :k43, :k44, :k45, :k46, :k47, :k48, :k49, :k50,
                                                :k51, :k52, :k53, :k54, :k55, :k56, :k57, :k58, :k59, :k60 );
            ASSERT_SQL;
            
            assert( gettimeofday( &endTime, NULL ) == 0 );
            
            if ( endTime.tv_usec > startTime.tv_usec ) {
                elapsed = ( endTime.tv_sec  - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec - startTime.tv_usec );
            } else {
                elapsed = ( endTime.tv_sec  - 1 - startTime.tv_sec ) * 1000000 + ( endTime.tv_usec + 1000000 - startTime.tv_usec );
            }
            
            if ( context->minimum > elapsed ) context->minimum = elapsed;
            if ( context->maximum < elapsed ) context->maximum = elapsed;
            context->sum += elapsed;
            context->numberOfTransactions++;
            if ( elapsed >= threshold ) context->numberOfLongTransactions++;
            
        }
        
    }
    
    EXEC SQL AT :connection DISCONNECT;
    ASSERT_SQL;
    
    return argument;
    
}

int main( int argc, char* argv[] ) {
    
    threadContext*      contexts;
    pthread_attr_t      threadAttribute;
    int                 thread;
    pthread_t*          threads;
    void*               value;
    struct tm*          tm;
    long long           second;
    long long           usecond;
    long long           elapsed;
    double              tps;
    int                 minimum;
    int                 maximum;
    long long           sum;
    int                 numberOfLongTransactions;
    int                 average;
    double              LongTransaction;
/*    
    numberOfThreads      = 1;
    startValue           = 0;
    numberOfTransactions = 1000000;
    sizeOfUnit           = 1000;
    threshold            = 1000000;
    cap                  = 0;
    strcpy( user,          "SYS" );
    strcpy( password,      "MANAGER" );
    strcpy( option,        "DSN=localhost;PORT_NO=20300;CONN_TYPE=2" );
*/    
    cap = 0;

    switch( argc ) {
     case 10:
        strcpy( option,        argv[9] );
     case 9:
        strcpy( password,      argv[8] );
     case 8:
        strcpy( user,          argv[7] );
     case 7:
        strcpy( test_mode,     argv[6] );
     case 6:
        threshold            = atoi( argv[5] );
     case 5:
        sizeOfUnit           = atoi( argv[4] );
     case 4:
        numberOfTransactions = atoi( argv[3] );
     case 3:
        startValue           = atoi( argv[2] );
     case 2:
        numberOfThreads      = atoi( argv[1] );
        break;
     default:
        printf( "Usage: %s numberOfThreads [startValue] [numberOfTransactions] [sizeOfUnit] [threshold] [test_mode] [user] [password] [option]\n", argv[0] );
        exit( EXIT_FAILURE );
        break;
    }
    
    printf( "Working Directory                 : %s\n",  workingDirectory()   );
    printf( "Test Mode                         : %s\n",  test_mode            );
    printf( "Number of Threads                 : %8d\n", numberOfThreads      );
    printf( "Start Value                       : %8d\n", startValue           );
    printf( "Number of Transactions            : %8d\n", numberOfTransactions );
    printf( "Size   of Unit                    : %8d\n", sizeOfUnit           );
    printf( "Threshold(microsecond)            : %8d\n", threshold            );
    printf( "Cap(TPS)                          : %8d\n", cap                  );
    printf( "User                              : %s\n",  user                 );
    printf( "Password                          : %s\n",  password             );
    printf( "Option                            : %s\n",  option               );
    
    contexts = malloc( sizeof(threadContext) * numberOfThreads );
    assert( contexts != NULL );
    memset( contexts, 0, sizeof(threadContext) * numberOfThreads );
    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        assert( pthread_mutex_init( &(contexts[thread].connected), NULL ) == 0 );
        sprintf( contexts[thread].connection, "%d", thread );
        contexts[thread].minimum                  = INT_MAX;
        contexts[thread].maximum                  = 0;
        contexts[thread].sum                      = 0;
        contexts[thread].numberOfTransactions     = 0;
        contexts[thread].numberOfLongTransactions = 0;
    }
    
    threads = malloc( sizeof(pthread_t) * numberOfThreads );
    assert( threads != NULL );
    
    mutex = malloc( sizeof(pthread_mutex_t) );
    assert( mutex != NULL );
    remain = malloc( sizeof(int) );
    assert( remain != NULL );
    cursor = malloc( sizeof(int) );
    assert( cursor != NULL );
    allocated = malloc( sizeof(int) );
    assert( allocated != NULL );
    
    assert( pthread_mutex_init( mutex, NULL ) == 0 );
    
    *remain    = numberOfTransactions;
    *cursor    = startValue;
    *allocated = 0;
    
    assert( pthread_attr_init( &threadAttribute ) == 0 );
    assert( pthread_attr_setscope( &threadAttribute, PTHREAD_SCOPE_SYSTEM ) == 0 );
    
    fflush( stdout );
    fflush( stderr );

    assert( gettimeofday( &connectTime, NULL ) == 0 );

    assert( pthread_mutex_lock( mutex ) == 0 );

    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        assert( pthread_mutex_lock( &(contexts[thread].connected) ) == 0 );
        assert( pthread_create( threads + thread, &threadAttribute, worker, contexts + thread ) == 0 );
    }

    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        assert( pthread_mutex_lock( &(contexts[thread].connected) ) == 0 );
        assert( pthread_mutex_unlock( &(contexts[thread].connected) ) == 0 );
    }

    assert( gettimeofday( &startTime, NULL ) == 0 );
    if ( startTime.tv_usec > connectTime.tv_usec ) {
        second  = startTime.tv_sec  - connectTime.tv_sec;
        usecond = startTime.tv_usec - connectTime.tv_usec;
    } else {
        second  = startTime.tv_sec  -       1 - connectTime.tv_sec;
        usecond = startTime.tv_usec + 1000000 - connectTime.tv_usec;
    }
    printf( "Connection Elapsed                : %llu.%06llu second\n", second, usecond );
    tm = localtime( &(startTime.tv_sec) );
    printf( "Start Time                        : %04u/%02u/%02u %02u:%02u:%02u.%06u\n", (unsigned int)(1900+tm->tm_year), (unsigned int)(tm->tm_mon+1), (unsigned int)(tm->tm_mday), (unsigned int)(tm->tm_hour), (unsigned int)(tm->tm_min), (unsigned int)(tm->tm_sec), (unsigned int)(startTime.tv_usec) );
    
    assert( pthread_mutex_unlock( mutex ) == 0 );
    
    fflush( stdout );
    fflush( stderr );
    
    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        assert( pthread_join( threads[thread], &value ) == 0 );
    }
    
    assert( gettimeofday( &endTime, NULL ) == 0 );
    tm = localtime( &(endTime.tv_sec) );
    printf( "End   Time                        : %04u/%02u/%02u %02u:%02u:%02u.%06u\n", (unsigned int)(1900+tm->tm_year), (unsigned int)(tm->tm_mon+1), (unsigned int)(tm->tm_mday), (unsigned int)(tm->tm_hour), (unsigned int)(tm->tm_min), (unsigned int)(tm->tm_sec), (unsigned int)(endTime.tv_usec) );
    
    assert( pthread_attr_destroy( &threadAttribute ) == 0 );
    
    assert( pthread_mutex_destroy( mutex ) == 0 );
    
    qsort( contexts, numberOfThreads, sizeof(threadContext), compareThreadContexts );
    
    minimum                  = INT_MAX;
    maximum                  = 0;
    sum                      = 0;
    numberOfLongTransactions = 0;
    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        if ( minimum > contexts[thread].minimum ) minimum = contexts[thread].minimum;
        if ( maximum < contexts[thread].maximum ) maximum = contexts[thread].maximum;
        sum                      += contexts[thread].sum;
        numberOfLongTransactions += contexts[thread].numberOfLongTransactions;
    }
    average = (int)( (double)sum / (double)numberOfTransactions );
    
    if ( endTime.tv_usec > startTime.tv_usec ) {
        second  = endTime.tv_sec  - startTime.tv_sec;
        usecond = endTime.tv_usec - startTime.tv_usec;
    } else {
        second  = endTime.tv_sec  -       1 - startTime.tv_sec;
        usecond = endTime.tv_usec + 1000000 - startTime.tv_usec;
    }
    printf( "Elapsed                           : %llu.%06llu second\n", second, usecond );
    
    elapsed = second * 1000000 + usecond;
    tps = (double)numberOfTransactions / ( (double)elapsed / 1e6 );
    LongTransaction = (double)numberOfLongTransactions / (double)numberOfTransactions * 100;
    printf( "Transactions per Second           : %9.2f TPS\n", tps );
    printf( "Minimum                           : %6d microseconds\n", minimum );
    printf( "Maximum                           : %6d microseconds\n", maximum );
    printf( "Average                           : %6d microseconds\n", average );
    printf( "Number of Long Transactions       : %6.2f%% ( %d / %d )\n", (double)numberOfLongTransactions / (double)numberOfTransactions * 100, numberOfLongTransactions, numberOfTransactions );
    printf( "Number of Transactions per Thread :" );
    for ( thread = 0; thread < numberOfThreads; thread++ ) {
        printf( " %d", contexts[thread].numberOfTransactions );
    }
    printf( "\n" );
    printf( "\n" );
    
    writeResult( test_mode, 2, numberOfThreads, tps, LongTransaction, minimum, maximum, average ); 
    return EXIT_SUCCESS;
    
}

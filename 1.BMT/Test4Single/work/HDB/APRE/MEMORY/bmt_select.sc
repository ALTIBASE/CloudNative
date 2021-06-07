void* worker ( void* argument ) {
    
    EXEC SQL BEGIN DECLARE SECTION;
    char connection[1024];
    int     p01;
    int     k01;
    char    k02[12];
    char    k04[11];
    char    k07[21];
    double  k11;
    char    k15[51];
    char    k21[4];
    char    k28[31];
    char    k38[101];
    int     k59;
    EXEC SQL END DECLARE SECTION;
    
    int            start;
    int            end;
    int            value;
    struct timeval startTime;
    struct timeval endTime;
    int            elapsed;
    
    threadContext* context = (threadContext*)argument;
    
    strcpy( connection, context->connection );
    
    EXEC SQL AT :connection CONNECT :user IDENTIFIED BY :password USING :option;
    ASSERT_SQL;
    
    assert( pthread_mutex_unlock( &(context->connected) ) == 0 );
    
    while ( allocateUnit( &start, &end ) > 0 ) {
        
        for ( value = start; value < end; value++ ) {
            
            assert( gettimeofday( &startTime, NULL ) == 0 );

            p01 = value;
            
            EXEC SQL AT :connection SELECT  K01,  K02,  K04,  K07,  K11,  K15,  K21,  K28,  K38,  K59
                                      INTO :k01, :k02, :k04, :k07, :k11, :k15, :k21, :k28, :k38, :k59
                                      FROM TEST
                                     WHERE K01 = :p01;
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

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

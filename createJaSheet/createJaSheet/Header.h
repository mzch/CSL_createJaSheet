//
//  Header.h
//  createJaSheet
//
//  Created by Koichi MATSUMOTO on 2016/02/25.
//  Copyright © 2016年 Koichi MATSUMOTO. All rights reserved.
//

#ifndef Header_h
#define Header_h

typedef struct {
    char * name;
    char * key;
    char * ref_name;   //
    char * ref_key;    //
    char * index;      //
    char * value;
    char * translation;
} LocaleTSV;

typedef struct {
    char * line_num;    // Line Number
    char * id;          //
    char * index;       //
    char * key;         //
    char * value;
    char * translation;
    char * note;
    
} TranslatedTSV;

#define TAB         '\t'
#define CRLF        '\n'
#define BUFFER_SIZE (8192 * 2)

typedef int BOOL;

#define NO      0;
#define OK      -1;

#endif /* Header_h */

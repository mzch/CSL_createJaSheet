//
//  main.m
//  createJaSheet
//
//  Created by Koichi MATSUMOTO on 2016/02/25.
//  Copyright © 2016年 Koichi MATSUMOTO. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "Header.h"

LocaleTSV getLocaleData(char * buf)
{
    LocaleTSV l;
    
    l.translation = l.value = l.index = l.ref_key = l.key = l.name = l.ref_name = "";
    
    char *p = strchr(buf, TAB);
    *p = '\0';
    l.name = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return l;
    *p = '\0';
    l.key = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return l;
    *p = '\0';
    l.ref_name = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return l;
    *p = '\0';
    l.ref_key = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return l;
    *p = '\0';
    l.index = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return l;
    *p = '\0';
    l.value = buf;
    
    return l;
}


TranslatedTSV getTranslationData(char * buf)
{
    TranslatedTSV t;
    
    t.index = t.value = t.id = t.key = t.translation = t.note = "";
    
    char *p = strchr(buf, TAB);
    if (! p)
        return t;
    *p = '\0';
    t.id = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return t;
    *p = '\0';
    t.index = buf;
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return t;
    *p = '\0';
    t.key = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return t;
    *p = '\0';
    t.value = buf;
    
    p++;
    buf = p;
    p = strchr(buf, TAB);
    if (! p)
        return t;
    *p = '\0';
    t.translation = buf;

    p++;
    buf = p;
    p = strchr(buf, CRLF);
    if (! p)
        return t;
    *p = '\0';
    t.note = buf;

    return t;
}

int main(int argc, const char * argv[])
{
    // check arguments
    if (argc < 5)
    {
        fprintf(stderr, "Missing arguments...\n");
        fprintf(stderr, "%s En.tsv Ja.tsv Output.tsv version\n\n", argv[0]);
        exit (1);
    }
    
    // check read in file
    FILE * fp_t = fopen(argv[1], "r");
    if (! fp_t)
    {
        fprintf(stderr, "File not found: %s\n", argv[1]);
        exit (2);
    }
    FILE * fp_s = fopen(argv[2], "r");
    if (! fp_s)
    {
        fprintf(stderr, "File not found: %s\n", argv[2]);
        exit (3);
    }
    FILE * fp_w = fopen(argv[3], "w");
    if (! fp_w)
    {
        fprintf(stderr, "File not open: %s\n", argv[3]);
        exit (4);
    }
    const char * version_string = argv[4];
    int line_num = 0;
    
    
    // Read Localization TSV
    char buf[BUFFER_SIZE];
    char org[BUFFER_SIZE];
    char out[BUFFER_SIZE];
    
    fgets(buf, sizeof(buf) - 1, fp_t);      // 先頭行読み捨て

    while (fgets(buf, sizeof(buf) - 1, fp_t))
    {
        line_num++;
        strcpy(org, buf);
        
        if (buf[0] != '#')
        {
            LocaleTSV l = getLocaleData(buf);

            if (l.value[0] == '[' && l.value[1] == '[')
            {
                continue;
            }

            char guf[BUFFER_SIZE];
            while (fgets(guf, sizeof(guf) - 1, fp_s))
            {
                TranslatedTSV t = getTranslationData(guf);
                
                char * crlf = strchr(t.translation, CRLF);
                if (! crlf)
                {
                    crlf = strchr(t.note, CRLF);
                }
                if (crlf)
                {
                    printf("Illegal translation with CRLF: %d", line_num);
                    exit (6);
                }
                
                if (! strcmp(l.ref_name, t.id) && ! strcmp(l.ref_key, t.index) && ! strcmp(l.index, t.key))
                {
                    sprintf(out, "%s\t%s\t%s\t%s\t%s\t%s\n", l.ref_name, l.ref_key, l.index, l.value, t.translation, t.note);
                    fputs(out, fp_w);
                    break;
                }
            }
            if (feof(fp_s))
            {
                sprintf(out, "%s\t%s\t%s\t%s\t\t%s にて追加\n", l.ref_name, l.ref_key, l.index, l.value, version_string);
                fputs(out, fp_w);
            }
            rewind(fp_s);
        }
    }
    
    fclose(fp_w);
    fclose(fp_s);
    fclose(fp_t);
    
    return 0;
}

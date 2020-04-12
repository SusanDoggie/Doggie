//
//  shim.c
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#include "shim.h"
#include <setjmp.h>

typedef struct _error_mgr {
    struct jpeg_error_mgr pub;
    jmp_buf jb;
    void (*error_exit) (j_common_ptr cinfo);
} error_mgr;

static void _error_exit(j_common_ptr cinfo)
{
    error_mgr *myerr = (error_mgr *)cinfo->err;
    myerr->error_exit(cinfo);
    longjmp(myerr->jb, 1);
}

bool _jpeg_read_header(j_decompress_ptr cinfo, boolean require_image)
{
    struct jpeg_error_mgr *jerr = cinfo->err;
    
    error_mgr _jerr;
    _jerr.pub = *cinfo->err;
    _jerr.error_exit = cinfo->err->error_exit;
    _jerr.pub.error_exit = _error_exit;
    
    cinfo->err = &_jerr.pub;
    
    if (setjmp(_jerr.jb)) {
        cinfo->err = jerr;
        return false;
    }
    
    jpeg_read_header(cinfo, require_image);
    
    cinfo->err = jerr;
    return true;
}

bool _jpeg_start_decompress(j_decompress_ptr cinfo)
{
    struct jpeg_error_mgr *jerr = cinfo->err;
    
    error_mgr _jerr;
    _jerr.pub = *cinfo->err;
    _jerr.error_exit = cinfo->err->error_exit;
    _jerr.pub.error_exit = _error_exit;
    
    cinfo->err = &_jerr.pub;
    
    if (setjmp(_jerr.jb)) {
        cinfo->err = jerr;
        return false;
    }
    
    jpeg_start_decompress(cinfo);
    
    cinfo->err = jerr;
    return true;
}

bool _jpeg_read_scanlines(j_decompress_ptr cinfo, JSAMPARRAY scanlines, JDIMENSION max_lines)
{
    struct jpeg_error_mgr *jerr = cinfo->err;
    
    error_mgr _jerr;
    _jerr.pub = *cinfo->err;
    _jerr.error_exit = cinfo->err->error_exit;
    _jerr.pub.error_exit = _error_exit;
    
    cinfo->err = &_jerr.pub;
    
    if (setjmp(_jerr.jb)) {
        cinfo->err = jerr;
        return false;
    }
    
    jpeg_read_scanlines(cinfo, scanlines, max_lines);
    
    cinfo->err = jerr;
    return true;
}

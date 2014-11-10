%{  

#include "y.tab.h"
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int line;
int new_line_error=0;
int array_check=0; 

void ERROR(const char msg[]);

#define MAX_INCLUDE_DEPTH 10
YY_BUFFER_STATE include_stack[MAX_INCLUDE_DEPTH];
int include_stack_ptr = 0;
%}


%option noyywrap
%option yylineno
%option stack
%x C_COMMENT
%x incl

        
     
/* ------------ Operators ------------ */


/* Binary Operators */

MINUS_						"-"
PLUS_        				"+"
TIMES_	    				"*"
DIV_						"/"
MOD_						"%"

/* Relational Operators */

ASSIGNMENT_					"="
EQUAL_						"=="
NOT_EQUAL_					"!="
GREATER_					">"
LESSER_						"<"
GREATER_EQUAL_				">="
LESSER_EQUAL_				"<="

/* Logical Operators */

OR_							"||"
AND_						"&&"
NOT_ 						"!"

/* ------------ KeyWords ------------ */

CHAR_						"char"
INTEGER_					"integer"
CONST_						"const"
VOID_						"void"
NEW_						"new"
CLASS_						"class"
IF_							"if"
ELSE_						"else"
WHILE_						"while"
RETURN_						"return"

/* ------------ Special Characters ------------ */

DOUBLE_QUOTE_				'\"'
QUOTE_ 						'\''
NULL_						'\0'
TAB_						'\t'
BACKSLASH_					'\\'
L_PAREN_      				"("
R_PAREN_     				")"
L_BRANK_					"{"
R_BRANK_					"}"
L_QBRANK_					"["
R_QBRANK_					"]"

COMMA_						","
QUESTIONMARK_				";"
COLON_						":"

/* ------------ Letters & Digits ------------ */

ZERO_DIGIT_					"0"
NON_ZERO_DIGIT_    			[1-9]
IDENTIFIER_	          		[a-zA-Z][a-z_A-Z0-9]*

%%	

{ASSIGNMENT_}       		{ printf("%s", yytext);	return ASSIGNMENT; }
{MINUS_}					{ printf("%s", yytext);	return MINUS; }
{PLUS_}						{ printf("%s", yytext);	return PLUS; }
{TIMES_}					{ printf("%s", yytext);	return TIMES; }
{DIV_}						{ printf("%s", yytext);	return DIV; }
{MOD_}						{ printf("%s", yytext);	return MOD; }
{EQUAL_} 				 	{ printf("%s", yytext);	return EQUAL; }
{NOT_EQUAL_}				{ printf("%s", yytext);	return NOT_EQUAL; }
{GREATER_}					{ printf("%s", yytext);	return GREATER; }
{LESSER_}					{ printf("%s", yytext);	return LESSER; 	}
{GREATER_EQUAL_}			{ printf("%s", yytext);	return GREATER_EQUAL; }
{LESSER_EQUAL_}				{ printf("%s", yytext);	return LESSER_EQUAL; }
{OR_}						{ printf("%s", yytext);	return OR; }
{AND_}						{ printf("%s", yytext);	return AND;	}
{CHAR_}						{ printf("%s", yytext);	return CHAR; }
{INTEGER_}					{ printf("%s", yytext);	return INTEGER; }
{L_PAREN_}      			{ printf("%s", yytext);	return L_PAREN; }
{R_PAREN_}					{ printf("%s", yytext);	return R_PAREN; }
{L_BRANK_}					{ printf("%s", yytext);	return L_BRANK; }
{R_BRANK_}					{ printf("%s", yytext);	return R_BRANK; }
{L_QBRANK_}					{ printf("%s", yytext);	return L_QBRANK; }
{R_QBRANK_}					{ printf("%s", yytext);	return R_QBRANK; }
{VOID_}						{ printf("%s", yytext);	return VOID; }
{NEW_}						{ printf("%s", yytext);	return NEW; }
{CLASS_}					{ printf("%s", yytext);	return CLASS; }
{IF_}						{ printf("%s", yytext);	return IF; }
{ELSE_}						{ printf("%s", yytext);	return ELSE; }
{WHILE_}					{ printf("%s", yytext);	return WHILE; }
{RETURN_}					{ printf("%s", yytext);	return RETURN; }
{QUOTE_}					{ printf("%s", yytext);	return QUOTE; }
{COMMA_}					{ printf("%s", yytext);	return COMMA; }
{QUESTIONMARK_}		  		{ printf("%s",yytext);	return QUEST_MARK; }
"\n"						{ printf("%s", yytext); ++line; }
{ZERO_DIGIT_}				{ printf("%s", yytext);	return ZERO_DIGIT; }
{NON_ZERO_DIGIT_}		 	{ printf("%s", yytext);	return non_zero_digit; }
{IDENTIFIER_}				{ printf("%s", yytext);	return identifier; }

#include BEGIN(incl);

<incl>[ \t]*    	/* eat the whitespace */
<incl>[^ \t\n]+ { 	/* got the include file name */
					if ( include_stack_ptr >= MAX_INCLUDE_DEPTH )
					{
						fprintf( stderr, "Includes nested too deeply" );
						exit( 1 );
					}

					include_stack[include_stack_ptr++] = YY_CURRENT_BUFFER;
					yyin = fopen( yytext, "r" );

					if ( ! yyin )	error();
					yy_switch_to_buffer( yy_create_buffer( yyin, YY_BUF_SIZE ) );
					BEGIN(INITIAL);
        		}

<<EOF>> {
			if ( --include_stack_ptr < 0 )
			{
				yyterminate();
			}

			else 
			{
				line = 0;
				yy_switch_to_buffer( include_stack[include_stack_ptr] );
			}        
		}


"/*"            		{ BEGIN(C_COMMENT); }
<C_COMMENT>"*/" 		{ BEGIN(INITIAL); }
<C_COMMENT>.    		{ }
<C_COMMENT>\n    		{ printf("\n"); ++line; }
<C_COMMENT>"x"    		{ printf("\n"); ++line; } 


%%
void ERROR(const char msg[])
{
   fprintf(stderr,"ERROR:%s\n",msg);
   exit(1);
}


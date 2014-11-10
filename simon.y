/* Gedit format
 *
 * Enea Tsanai			4828
 * Mixahl Drakoulelis 	4442
 *
 */

%{


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int line;
FILE *yyin;
void yyerror(char *errorinfo);
int yydebug=1;
int error_count = 0;


%}


/* Bison declarations. */

%token CLASS
%token ASSIGNMENT
%token MINUS PLUS DIV TIMES MOD NOT
%token IF ELSE WHILE 
%token RETURN
%token OR AND EQUAL NOT_EQUAL GREATER LESSER LESSER_EQUAL GREATER_EQUAL
%token NEW
%token INTEGER CHAR VOID
%token identifier letter
%token ZERO_DIGIT non_zero_digit
%token L_PAREN R_PAREN L_BRANK R_BRANK L_QBRANK R_QBRANK
%token QUOTE COMMA QUEST_MARK

%nonassoc "then"
%nonassoc ELSE

%start class_declarations



%% /* The grammar follows. */



class_declarations : class_declaration
									 | class_declaration  class_declarations ;

class_declaration : CLASS identifier class_body
									| CLASS identifier error class_body ;

class_body : L_BRANK R_BRANK
					 | L_BRANK class_body_declarations R_BRANK ;

class_body_declarations : class_body_declaration
												| class_body_declarations class_body_declaration ;

class_body_declaration : class_member_declaration
											 | constructor_declaration ;

class_member_declaration : field_declaration
												 | type method_declaration
						 						 | VOID method_declaration ;

constructor_declaration : constructor_declarator constructor_body ;

constructor_declarator : identifier L_PAREN R_PAREN
											 | identifier L_PAREN formal_parameter_list R_PAREN ;

formal_parameter_list : formal_parameter
					  					| formal_parameter_list COMMA formal_parameter ;

formal_parameter : type variable_declarator_id;

constructor_body : L_BRANK block_statements R_BRANK ;

field_declaration : variable_declarators QUEST_MARK 
									| variable_declarator QUEST_MARK 
								 	| variable_declarators error 
									| variable_declarator error ;

variable_declarators : type variable_declarator
										 | variable_declarators COMMA variable_declarator;

variable_declarator : variable_declarator_id
										| variable_declarator_id ASSIGNMENT variable_initializer ;

variable_declarator_id : identifier
											 | identifier L_QBRANK R_QBRANK ;

variable_initializer : expression ;

method_declaration : method_header method_body ;

method_header : method_declarator ;

method_declarator : identifier L_PAREN R_PAREN
									| identifier L_PAREN formal_parameter_list R_PAREN ;

method_body : block
						| QUEST_MARK ;

block : L_BRANK R_BRANK
			| L_BRANK block_statements R_BRANK ;

block_statements : block_statement
								 | block_statements block_statement ;
								 
block_statement : variable_declarators
								| statement 
								| method_invocation QUEST_MARK
								| method_invocation error ;

statement : statement_without_trailing_substatement
					| if_statements
					| while_statement ;

if_statements : IF L_PAREN conditional_expression R_PAREN statement %prec "then"
							| IF L_PAREN conditional_expression R_PAREN statement ELSE statement  ;

statement_without_trailing_substatement : block
																				| empty_statement
																				| assignment
																				| return_statement ;

empty_statement : QUEST_MARK ;

while_statement : WHILE L_PAREN conditional_expression R_PAREN statement ;

return_statement : RETURN QUEST_MARK
								 | RETURN expression QUEST_MARK 
								 | RETURN error
								 | RETURN expression error;

conditional_expression : conditional_not_expression ;

conditional_not_expression : NOT conditional_or_expression
						   						 | conditional_or_expression ;

conditional_or_expression : conditional_and_expression
													| conditional_and_expression OR conditional_and_expression ;

conditional_and_expression : equality_expression
													 | conditional_and_expression AND equality_expression ;

equality_expression : relational_expression B ;

B : EQUAL relational_expression B
  | NOT_EQUAL relational_expression B | ;

relational_expression : additive_expression C ;

C : LESSER additive_expression C
  | GREATER additive_expression C
  | LESSER_EQUAL additive_expression C
  | GREATER_EQUAL additive_expression C
  | ;

expression : assignment_expression ;

assignment_expression : additive_expression
					  					| assignment ;

assignment : left_hand_side ASSIGNMENT assignment_expression QUEST_MARK 
					 | left_hand_side ASSIGNMENT assignment_expression error ;

left_hand_side : identifier
			   			 | array_access ;

additive_expression : multiplicative_expression D ;

D : PLUS multiplicative_expression D
  | MINUS multiplicative_expression D
  | ;

multiplicative_expression : unary_expression E ;

E : TIMES unary_expression E
  | DIV unary_expression E
  | MOD unary_expression E
  | ;

unary_expression : PLUS unary_expression
								 | MINUS unary_expression
								 | unary_expression_not_plus_minus ;

unary_expression_not_plus_minus : primary
																| identifier ;

primary : primary_no_new_array
				| array_creation_expression ;

primary_no_new_array : literal
										 | L_PAREN expression R_PAREN
										 | class_instance_creation_expression
										 | method_invocation
										 | array_access ;

class_instance_creation_expression : NEW identifier L_PAREN R_PAREN 
																	 | NEW identifier L_PAREN argument_list R_PAREN;

argument_list : expression
			  			| argument_list COMMA expression ;

array_creation_expression : NEW primitive_type dim_exprs 
													| NEW identifier dim_exprs ;

dim_exprs : dim_expr
		  		| dim_exprs dim_expr ;

dim_expr : L_QBRANK expression R_QBRANK ;

array_access : identifier L_QBRANK expression R_QBRANK
						 | array_access L_QBRANK expression R_QBRANK ;

method_invocation : method_name METHODNAME_ ;

METHODNAME_ : L_PAREN R_PAREN | L_PAREN argument_list R_PAREN ;

method_name : identifier ;

literal : integer_literal
				| character_literal ;

integer_literal : decimal_numeral ;

character_literal : QUOTE single_character QUOTE ;

single_character : letter ;

decimal_numeral : ZERO_DIGIT
								| non_zero_digit non_zero_digit_;

non_zero_digit_ : digits
								| ;

digits : digit digit_ ;
digit_ : digit digit_
			 | ;

digit : ZERO_DIGIT
	  	| non_zero_digit ;

type : primitive_type
		 | reference_type ;

primitive_type : INTEGER
			  			 | CHAR ;

reference_type : identifier ;



%%

	main(int argc, char *argv[])
	{
	
		int res;
		++argv;
		--argc;

		if (argv>0)
		{
			yyin=fopen(argv[0],"r");
			res=yyparse();
		}
	
		if(res==0)
		{
		  if( error_count == 0 )
			{
					printf("\n\n PARSER REACHED END \n");
	        printf("______________________\n");
					printf("|                     |\n");
					printf("    No syntax error!\n");
					printf("|_____________________|\n");			
			}
			else
			{
					printf("\n\n PARSER REACHED END \n");
	        printf("____________________\n");
					printf("|                   |\n");
					printf("    Syntax error!\n");
				 	printf("    Errors: %d         \n", error_count);
					printf("|___________________|\n");			
			}
		}
	}

	void yyerror(char *msg)
	{
		error_count ++ ;
		printf("\nlog::** Errors: %d **\n", error_count);		
	  puts("-----------------------------------");
		printf("Error: line %d: %s  \n",line, msg);
		puts("-----------------------------------");
	}


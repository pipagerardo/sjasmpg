/*

  Sjasm Z80 Assembler version 0.42

  Copyright 2011 Sjoerd Mastijn

  This software is provided 'as-is', without any express or implied warranty.
  In no event will the authors be held liable for any damages arising from the
  use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it freely,
  subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not claim
     that you wrote the original software. If you use this software in a product,
     an acknowledgment in the product documentation would be appreciated but is
     not required.

  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.

  3. This notice may not be removed or altered from any source distribution.

*/

/*
	Copyright 2017 PipaGerardo               E-Mail: pipagerardo@gmail.com
	SjasmPG Ensamblador para el microprocesador de 8 bits Z80
	Basado en Sjasm v42c de Sjoerd Mastijn Copyright 2011 - www.xl2s.tk
*/

#ifndef _SJASM_LANGUAGE_UTF8_
#define _SJASM_LANGUAGE_UTF8_

#ifdef SPANISH

// Genéricos:
#define EM_Syntax_error	                "Error de sintaxis"
#define EM_Overflow				        "Desbordamiento"
#define EM_Hoppa_Noppa			        "¡Toma castaña!"
#define EM_Illegal_operand		        "Operando no permitido"
#define EM_Illegal_parameter	        "Parámetro ilícito"
#define EM_Illegal_range		        "Rango ilegal"
#define EM_Unknown_instruction	        "Instrucción desconocida"
#define EM_Forward_reference	        "Referencia adelante"
#define EM_Expression_expected	        "Expresión esperada"
#define EM_Parameter_missing	        "Parámetro ausente"
#define EM_Operand_expected 	        "Operando esperado"
#define EM_Division_by_zero 	        "División por cero\n"
// Tamaño:
#define EM_Too_much_data 		        "Demasiados datos"
#define EM_Negative_size		        "Tamaño negativo"
#define EM_Size_expected		        "Tamaño esperado"
#define EM_Size_already_set		        "Tamaño ya establecido"
#define EM_Maximum_part_size_256        "Se ha superado el máximo de la pieza (256)"
#define EM_Part_does_not_fit	        "La pieza no encaja"
// Lógica:
#define EM_Unexpected                   "Inesperado"
#define EM_Base_expected                "Base esperada"
#define EM_Increment_expected		    "Incremento esperado"
#define EM_Cannot_negate_condition	    "No se puede negar la condición"
#define EM_Negative_origin			    "Origen negativo"
#define EM_Digit_not_in_base		    "Dígito no en base"
#define EM_No_default_allowed 		    "¡Valor predeterminado no permitido!"
#define EM_No_greedy_stars_allowed	    "¡Ninguna estrella codiciosa permitida!"
// Closing:
#define EM_No_closing_B				    "Sin cerrar '\"'"
#define EM_No_closing_R 			    "Sin cerrar '>'"
#define EM_Closing_P_expected 		    "Cierre de ) esperado"
#define EM_Closing_C_expected 		    "Cierre de ] esperado"
// Valor / Objetivo:
#define EM_Default_value_expected	    "Valor predeterminado esperado"
#define EM_Value_out_of_range		    "Valor fuera de rango"
#define EM_Target_out_of_range		    "Objetivo fuera de rango ("
// Sobrecarga:
#define EM_Overlay_code_part_needs      "Parte del código de superposición necesita una dirección"
#define EM_Overlapping_routines		    "Rutinas superpuestas"
#define EM_Overloading_not_allowed 	    "No se permite la sobrecarga"
// Cadenas:
#define EM_String_expected			    "Cadena esperada"
#define EM_Unexpected_end_of_string	    "Final inesperado de la cadena"
#define EM_Empty_string_not_allowed	    "Cadena vacía no permitida"
#define EM_Constant_expected 		    "Constante esperada"
// Carácteres:
#define EM_Illegal_character		    "Carácter(es) ilegal(es)"
#define EM_Character_range_expected	    "Carácter(rango) esperado"
#define EM_Comma_expected 			    "Coma esperada"
#define EM_Unknown_escape 			    "Escape desconocido"
// Label:
#define EM_Illegal_label_name		    "Nombre de etiqueta no válido"
#define EM_Label_not_found			    "Etiqueta no encontrada"
#define EM_Duplicate_labelname		    "Nombre de etiqueta duplicado"
#define EM_Label_already_exists 	    "La etiqueta ya existe"
#define EM_Mixing_set_normal_labels     "Mezcla de etiquetas fijas y normales no permitidas"
#define EM_Numberlabels_only_allowed    "Las etiquetas numéricas sólo se permiten como etiquetas de dirección"
// Macro:
#define EM_Illegal_macroname 		    "Nombre de macro no válido"
#define EM_Illegal_macro_definition	    "Definición de macro ilegal"
#define EM_Macro_already_exists 	    "Macro ya existe"
#define EM_Indirection_not_allowed	    "Indirección no permitida"
#define EM_Use_rotate_outside_macro	    "Uso de rotación no permitido fuera de macro"
#define EM_Use_num_outside_macro	    "El uso de @num no se permite fuera de macro"
#define EM_Use_num_outside_loops	    "El uso de @ # no se permite fuera de bucles"
#define EM_ENDMACRO_without_MACRO	    "ENDMACRO sin MACRO"
#define EM_EXITMACRO_outside_macro	    "EXITMACRO usado fuera de macro"
#define EM_XEXITMACRO_outside_macro	    "XEXITMACRO usado fuera de macro"
// Struct:
#define EM_Illegal_structure_name	    "Nombre de estructura no válida"
#define EM_Label_structure_not_found    "Etiqueta definida por estructura no encontrada"
#define EM_Structure_already_exists	    "La estructura ya existe"
#define EM_ENDSTRUCT_without_STRUCT     "ENDSTRUCT sin STRUCT"
// Offest / Address / Align:
#define EM_Invalid_addressrange		    "Rango de direcciones no válido"
#define EM_Illegal_addressmode		    "Modo de dirección no válido :)"
#define EM_Illegal_alignment		    "Alineamiento ilegal"
#define EM_Offset_expected			    "Desplazamiento esperado"
#define EM_Offsets_not_allowed_jumps    "Desplazamiento no permitido con saltos"
#define EM_Offset_out_of_range		    "Desplazamiento fuera de rango"
#define EM_Alignment_expected		    "Alineación esperada"
#define EM_Alignment_value_expected	    "Valor de alineación esperado"
#define EM_Alignment_shouldbepositiv    "La alineación debe ser positiva"
#define EM_Unknown_alignmode		    "Modo de alineamiento desconocido"
#define EM_Negative_zero_alignment	    "Alineación negativa o cero no permitida"
#define EM_Negative_block_notallowed    "Bloque negativo no permitido"
#define EM_Negative_offsetnotallowed    "No se permite esplazamiento negativo"
#define EM_Negative_lengthnotallowed    "No se permite longitud negativa"
#define EM_file_size_not_allowed	    "Desplazamiento + Longitud > Tamaño de archivo no permitido"
#define EM_Assertion_failed			    "Error de aserción"
// Defines:
#define EM_Illegal_define_name 		    "Nombre de la Definición no permitido"
#define EM_ReplaceDefines			    "Reemplaz Definición"
#define EM_Redefinition_multiparamet    "No se permite la redefinición de multiparámetros"
#define EM_Cant_undef_a_define_with     "No se puede desdefinir una definición con argumentos"
// Page:
#define EM_Illegal_pagenumber		    "Número de página ilegal"
#define EM_Invalid_pagerange		    "Rango de página no válido"
#define EM_Page_already_exists		    "La página ya existe"
#define EM_Page_does_not_exist		    "La página no existe"
#define EM_Unknown_multipagemode	    "Modo multipágina desconocido"
// Module:
#define EM_ENDMODULE_without_MODULE	    "ENDMODULE sin MODULE"
#define EM_MODULE_not_found			    "MODULE no encontrado"
// BUCLES IF ELSE WHILE:
#define EM_IF_without_ENDIF			    "IF sin ENDIF"
#define EM_ELSEIF_without_IF		    "ELSEIF sin IF"
#define EM_ELSEIF_within_ELSE		    "ELSEIF dentro ELSE"
#define EM_ELSE_without_IF			    "ELSE sin IF"
#define EM_ELSE_within_ELSE			    "ELSE dentro ELSE"
#define EM_ENDIF_without_IF			    "ENDIF sin IF"
#define EM_ENDWHILE_without_WHILE	    "ENDWHILE sin WHILE"
#define EM_ENDREPEAT_without_REPEAT	    "ENDREPEAT sin REPEAT"
#define EM_BREAK_used_outside_loop	    "BREAK usado fuera de un bucle"
#define EM_CONTINUE_outside_loop	    "CONTINUE usado fuera de un bucle"
#define EM_Negative_repeat_value	    "Valor de repetición negativo"
#define EM_Negative_repeat_count	    "Número de repetición negativo"
#define EM_Nothing_to_repeat		    "Nada que repetir"
#define EM_without_repeatblock		    "% sin bloque de repetición"
// CODE / MAP / PHASE:
#define EM_CODE_not_allowed_in_PHASE    "CODE no permitido en bloque PHASE"
#define EM_ENDMAP_without_MAP		    "ENDMAP sin MAP"
#define EM_PHASE_without_PHASE		    "PHASE sin DEPHASE"
#define EM_DEPHASE_without_PHASE	    "DEPHASE sin PHASE"
// File:
#define EM_Error_opening_file 		    "Error al abrir el archivo"
#define EM_Write_error				    "Error de escritura"
#define EM_Unexpected_end_of_file 	    "Inesperado final de archivo"
#define EM_No_inputfile				    "Sin archivo de entrada"

// TEXTOS:
#define TXT_Assambler_v                 "SjasmPG Z80 Ensamblador v"
#define TXT_Based_on_Sjasm              "Basado en Sjasm v42c de Sjoerd Mastijn - www.xl2s.tk\n"

#define TXT_OPTION_01 "\nUso:\nsjasmpg [-opciones] archivo_entrada [archivo_salida [parámetros]]\n"
#define TXT_OPTION_02 "\nLas opciones son las siguientes:\n";
#define TXT_OPTION_03 "  -s        Genera un archivo de símbolos .SYM\n";
#define TXT_OPTION_04 "  -q        Sin listado\n";
#define TXT_OPTION_05 "  -i<path>  Ruta de Inclusión\n";
#define TXT_OPTION_06 "  -j        Optimiza los saltos\n";
#define TXT_OPTION_07 "  -p        Paréntesis como indirecciones de memoria\n";

#define TXT_Unrecognised_option         "Opción no reconocida: "
#define TXT_Too_many_command_line_para  "Demasiados parámetros de línea de comandos"
#define TXT_LABELS                      "    ETIQUETAS"
#define TXT_see                         ") : mira "
#define TXT_Line_Pag_Value_Complet      "Línea\tPág:Dirección \tValor\t\tLínea Completa"
#define TXT_Errors                      "Errores: "
#define TXT_Size                        "  Tamaño: "
#define TXT_Overlay_parts               "  Partes superpuestas:"
#define TXT_Address_Length_Label        "   Dirección Alineación     Etiqueta"
#define TXT_Page                        " Página: "
#define TXT_does_not_fit_in_page        " no encaja en la página"
#define TXT_No_output                   "    Ninguna salida"
#define TXT_empty                       "       <vacio>"
#define TXT_Output                      " Salida: "
#define TXT_Used                        "  Usado: "
#define TXT_Part                        "Parte"


#else


// Generic:
#define EM_Syntax_error				    "Syntax error"
#define EM_Overflow					    "Overflow"
#define EM_Hoppa_Noppa				    "Hoppa? Noppa!"
#define EM_Illegal_operand			    "Illegal operand"
#define EM_Illegal_parameter	        "Illegal parameter"
#define EM_Illegal_range			    "Illegal range"
#define EM_Unknown_instruction	        "Unknown instruction"
#define EM_Forward_reference	        "Forward reference"
#define EM_Expression_expected	        "Expression expected"
#define EM_Parameter_missing	        "Parameter missing"
#define EM_Operand_expected 	        "Operand expected"
#define EM_Division_by_zero 	        "Division by zero\n"
// Size:
#define EM_Too_much_data 	            "Too much data"
#define EM_Negative_size			    "Negative size"
#define EM_Size_expected			    "Size expected"
#define EM_Size_already_set		        "Size already set"
#define EM_Maximum_part_size_256	    "Maximum part size (256) exceeded"
#define EM_Part_does_not_fit		    "Part does not fit"
// Logic:
#define EM_Unexpected				    "Unexpected"
#define EM_Base_expected			    "Base expected"
#define EM_Increment_expected		    "Increment expected"
#define EM_Cannot_negate_condition      "Cannot negate condition"
#define EM_Negative_origin			    "Negative origin"
#define EM_Digit_not_in_base		    "Digit not in base"
#define EM_No_default_allowed 	        "No default allowed!"
#define EM_No_greedy_stars_allowed	    "No greedy stars allowed!"
// Closing:
#define EM_No_closing_B			        "No closing '\"'"
#define EM_No_closing_R 		        "No closing '>'"
#define EM_Closing_P_expected 	        "Closing ) expected"
#define EM_Closing_C_expected 	        "Closing ] expected"
// Value / Target:
#define EM_Default_value_expected       "Default value expected"
#define EM_Value_out_of_range	        "Value out of range"
#define EM_Target_out_of_range	        "Target out of range ("
// Over:
#define EM_Overlay_code_part_needs      "Overlay code part needs a address"
#define EM_Overlapping_routines	        "Overlapping routines"
#define EM_Overloading_not_allowed      "Overloading not allowed"
// String:
#define EM_String_expected			    "String expected"
#define EM_Unexpected_end_of_string	    "Unexpected end of string"
#define EM_Empty_string_not_allowed	    "Empty string not allowed"
#define EM_Constant_expected 		    "Constant expected"
// Chars:
#define EM_Illegal_character		    "Illegal character(s)"
#define EM_Character_range_expected     "Character(range) expected"
#define EM_Comma_expected 	            "Comma expected"
#define EM_Unknown_escape 		        "Unknown escape"
// Label:
#define EM_Illegal_label_name           "Illegal label name"
#define EM_Label_not_found		        "Label not found"
#define EM_Duplicate_labelname	        "Duplicate labelname"
#define EM_Label_already_exists 	    "Label already exists"
#define EM_Mixing_set_normal_labels     "Mixing of set and normal labels not allowed"
#define EM_Numberlabels_only_allowed    "Numberlabels only allowed as adresslabels"
// Macro:
#define EM_Illegal_macroname            "Illegal macroname"
#define EM_Illegal_macro_definition	    "Illegal macro definition"
#define EM_Macro_already_exists 	    "Macro already exists"
#define EM_Indirection_not_allowed      "Indirection not allowed"
#define EM_Use_rotate_outside_macro     "Use of rotate not allowed outside macro"
#define EM_Use_num_outside_macro        "Use of @num not allowed outside macro"
#define EM_Use_num_outside_loops	    "Use of @# not allowed outside loops"
#define EM_ENDMACRO_without_MACRO       "ENDMACRO without MACRO"
#define EM_EXITMACRO_outside_macro      "EXITMACRO used outside macro"
#define EM_XEXITMACRO_outside_macro	    "XEXITMACRO used outside macro"
// Struct:
#define EM_Illegal_structure_name       "Illegal structure name"
#define EM_Label_structure_not_found    "Label defined by structure not found?"
#define EM_Structure_already_exists     "Structure already exists"
#define EM_ENDSTRUCT_without_STRUCT     "ENDSTRUCT without STRUCT"
// Offest / Address / Align:
#define EM_Invalid_addressrange	        "Invalid addressrange"
#define EM_Illegal_addressmode	        "Illegal addressmode :)"
#define EM_Illegal_alignment		    "Illegal alignment"
#define EM_Offset_expected		        "Offset expected"
#define EM_Offsets_not_allowed_jumps    "Offsets not allowed with jumps"
#define EM_Offset_out_of_range		    "Offset out of range"
#define EM_Alignment_expected	        "Alignment expected"
#define EM_Alignment_value_expected	    "Alignment value expected"
#define EM_Alignment_shouldbepositiv    "Alignment should be positive"
#define EM_Unknown_alignmode		    "Unknown alignmode"
#define EM_Negative_zero_alignment	    "Negative or zero alignment not allowed"
#define EM_Negative_block_notallowed    "Negative block not allowed"
#define EM_Negative_offsetnotallowed    "Negative offset is not allowed"
#define EM_Negative_lengthnotallowed    "Negative length is not allowed"
#define EM_file_size_not_allowed	    "offset+length>file size not allowed"
#define EM_Assertion_failed	            "Assertion failed"
// Defines:
#define EM_Illegal_define_name 	        "Illegal define name"
#define EM_ReplaceDefines			    "ReplaceDefines"
#define EM_Redefinition_multiparamet    "Redefinition of multiparameter define not allowed"
#define EM_Cant_undef_a_define_with     "Can't undef a define with arguments"
// Page:
#define EM_Illegal_pagenumber	        "Illegal pagenumber"
#define EM_Invalid_pagerange		    "Invalid pagerange"
#define EM_Page_already_exists	        "Page already exists"
#define EM_Page_does_not_exist	        "Page does not exist"
#define EM_Unknown_multipagemode	    "Unknown multipagemode"
// Module:
#define EM_ENDMODULE_without_MODULE     "ENDMODULE without MODULE"
#define EM_MODULE_not_found			    "MODULE not found"
// BUCLES IF ELSE WHILE:
#define EM_IF_without_ENDIF		        "IF without ENDIF"
#define EM_ELSEIF_without_IF		    "ELSEIF without IF"
#define EM_ELSEIF_within_ELSE	        "ELSEIF within ELSE"
#define EM_ELSE_without_IF			    "ELSE without IF"
#define EM_ELSE_within_ELSE		        "ELSE within ELSE"
#define EM_ENDIF_without_IF			    "ENDIF without IF"
#define EM_ENDWHILE_without_WHILE       "ENDWHILE without WHILE"
#define EM_ENDREPEAT_without_REPEAT	    "ENDREPEAT without REPEAT"
#define EM_BREAK_used_outside_loop	    "BREAK used outside loop"
#define EM_CONTINUE_outside_loop	    "CONTINUE used outside loop"
#define EM_Negative_repeat_value	    "Negative repeat value"
#define EM_Negative_repeat_count	    "Negative repeat count"
#define EM_Nothing_to_repeat		    "Nothing to repeat"
#define EM_without_repeatblock		    "% without repeatblock"
// CODE / MAP / PHASE:
#define EM_CODE_not_allowed_in_PHASE    "CODE not allowed in PHASE block"
#define EM_ENDMAP_without_MAP	        "ENDMAP without MAP"
#define EM_PHASE_without_PHASE		    "PHASE without DEPHASE"
#define EM_DEPHASE_without_PHASE	    "DEPHASE without PHASE"
// File:
#define EM_Error_opening_file 	        "Error opening file"
#define EM_Write_error			        "Write error"
#define EM_Unexpected_end_of_file       "Unexpected end of file"
#define EM_No_inputfile			        "No inputfile"

// TEXTS:
#define TXT_Assambler_v                 "SjasmPG Z80 Assembler v"
#define TXT_Based_on_Sjasm              "Based on Sjasm v42c by Sjoerd Mastijn - www.xl2s.tk\n"

#define TXT_OPTION_01 "\nUsage:\nsjasmpg [-options] sourcefile [targetfile [parameters]]\n";
#define TXT_OPTION_02 "\nOption flags as follows:\n";
#define TXT_OPTION_03 "  -s        Generate .SYM symbol file\n";
#define TXT_OPTION_04 "  -q        No listing\n";
#define TXT_OPTION_05 "  -i<path>  Includepath\n";
#define TXT_OPTION_06 "  -j        Optimize jumps\n";
#define TXT_OPTION_07 "  -p        Parentheses as memory indirections\n";

#define TXT_Unrecognised_option         "Unrecognised option: "
#define TXT_Too_many_command_line_para  "Too many command line parameters"
#define TXT_LABELS                      "    LABELS"
#define TXT_see                         ") : see "
#define TXT_Line_Pag_Value_Complet      "Line \tPag:Direcction\tValue\t\tComplet Line"
#define TXT_Errors                      "Errors: "
#define TXT_Size                        "  Size: "
#define TXT_Overlay_parts               "  Overlay parts:"
#define TXT_Address_Length_Label        "   Address   Length Align   Label"
#define TXT_Page                        " Page: "
#define TXT_does_not_fit_in_page        " does not fit in page"
#define TXT_No_output                   "    No output"
#define TXT_empty                       "       <empty>"
#define TXT_Output                      " Output: "
#define TXT_Used                        "  Used: "
#define TXT_Part                        "Part"

#endif

#endif

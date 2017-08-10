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

// errors.cpp
#include "sjasmpg.h"
// #include "errors.h"

#ifdef LANGUAGE_UTF8
#include "language_utf8.h"
#else
#include "language_iso.h"
#endif

/*
#ifdef SPANISH
// Genéricos:
string EM_Syntax_error				= "Error de sintaxis";
string EM_Overflow					= "Desbordamiento";
string EM_Hoppa_Noppa				= "¡Toma castaña!";
string EM_Illegal_operand			= "Operando no permitido";
string EM_Illegal_parameter			= "Parámetro ilícito";
string EM_Illegal_range				= "Rango ilegal";
string EM_Unknown_instruction		= "Instrucción desconocida";
string EM_Forward_reference			= "Referencia adelante";
string EM_Expression_expected		= "Expresión esperada";
string EM_Parameter_missing			= "Parámetro ausente";
string EM_Operand_expected 			= "Operando esperado";
string EM_Division_by_zero 			= "División por cero\n";
// Tamaño:
string EM_Too_much_data 			= "Demasiados datos";
string EM_Negative_size				= "Tamaño negativo";
string EM_Size_expected				= "Tamaño esperado";
string EM_Size_already_set			= "Tamaño ya establecido";
string EM_Maximum_part_size_256		= "Se ha superado el máximo de la pieza (256)";
string EM_Part_does_not_fit			= "La pieza no encaja";
// Lógica:
string EM_Unexpected				= "Inesperado";
string EM_Base_expected				= "Base esperada";
string EM_Increment_expected		= "Incremento esperado";
string EM_Cannot_negate_condition	= "No se puede negar la condición";
string EM_Negative_origin			= "Origen negativo";
string EM_Digit_not_in_base			= "Dígito no en base";
string EM_No_default_allowed 		= "¡Valor predeterminado no permitido!";
string EM_No_greedy_stars_allowed	= "¡Ninguna estrella codiciosa permitida!";
// Closing:
string EM_No_closing_B				= "Sin cerrar '\"'";
string EM_No_closing_R 				= "Sin cerrar '>'";
string EM_Closing_P_expected 		= "Cierre de ) esperado";
string EM_Closing_C_expected 		= "Cierre de ] esperado";
// Valor / Objetivo:
string EM_Default_value_expected	= "Valor predeterminado esperado";
string EM_Value_out_of_range		= "Valor fuera de rango";
string EM_Target_out_of_range		= "Objetivo fuera de rango (";
// Sobrecarga:
string EM_Overlay_code_part_needs	= "Parte del código de superposición necesita una dirección";
string EM_Overlapping_routines		= "Rutinas superpuestas";
string EM_Overloading_not_allowed 	= "No se permite la sobrecarga";
// Cadenas:
string EM_String_expected			= "Cadena esperada";
string EM_Unexpected_end_of_string	= "Final inesperado de la cadena";
string EM_Empty_string_not_allowed	= "Cadena vacía no permitida";
string EM_Constant_expected 		= "Constante esperada";
// Carácteres:
string EM_Illegal_character			= "Carácter(es) ilegal(es)";
string EM_Character_range_expected	= "Carácter(rango) esperado";
string EM_Comma_expected 			= "Coma esperada";
string EM_Unknown_escape 			= "Escape desconocido";
// Label:
string EM_Illegal_label_name		= "Nombre de etiqueta no válido";
string EM_Label_not_found			= "Etiqueta no encontrada";
string EM_Duplicate_labelname		= "Nombre de etiqueta duplicado";
string EM_Label_already_exists 		= "La etiqueta ya existe";
string EM_Mixing_set_normal_labels  = "Mezcla de etiquetas fijas y normales no permitidas";
string EM_Numberlabels_only_allowed = "Las etiquetas numéricas sólo se permiten como etiquetas de dirección";
// Macro:
string EM_Illegal_macroname 		= "Nombre de macro no válido";
string EM_Illegal_macro_definition	= "Definición de macro ilegal";
string EM_Macro_already_exists 		= "Macro ya existe";
string EM_Indirection_not_allowed	= "Indirección no permitida";
string EM_Use_rotate_outside_macro	= "Uso de rotación no permitido fuera de macro";
string EM_Use_num_outside_macro		= "El uso de @num no se permite fuera de macro";
string EM_Use_num_outside_loops		= "El uso de @ # no se permite fuera de bucles";
string EM_ENDMACRO_without_MACRO	= "ENDMACRO sin MACRO";
string EM_EXITMACRO_outside_macro	= "EXITMACRO usado fuera de macro";
string EM_XEXITMACRO_outside_macro	= "XEXITMACRO usado fuera de macro";
// Struct:
string EM_Illegal_structure_name	= "Nombre de estructura no válida";
string EM_Label_structure_not_found = "Etiqueta definida por estructura no encontrada";
string EM_Structure_already_exists	= "La estructura ya existe";
string EM_ENDSTRUCT_without_STRUCT	= "ENDSTRUCT sin STRUCT";
// Offest / Address / Align:
string EM_Invalid_addressrange		= "Rango de direcciones no válido";
string EM_Illegal_addressmode		= "Modo de dirección no válido :)";
string EM_Illegal_alignment			= "Alineamiento ilegal";
string EM_Offset_expected			= "Desplazamiento esperado";
string EM_Offsets_not_allowed_jumps = "Desplazamiento no permitido con saltos";
string EM_Offset_out_of_range		= "Desplazamiento fuera de rango";
string EM_Alignment_expected		= "Alineación esperada";
string EM_Alignment_value_expected	= "Valor de alineación esperado";
string EM_Alignment_shouldbepositiv = "La alineación debe ser positiva";
string EM_Unknown_alignmode			= "Modo de alineamiento desconocido";
string EM_Negative_zero_alignment	= "Alineación negativa o cero no permitida";
string EM_Negative_block_notallowed = "Bloque negativo no permitido";
string EM_Negative_offsetnotallowed = "No se permite esplazamiento negativo";
string EM_Negative_lengthnotallowed = "No se permite longitud negativa";
string EM_file_size_not_allowed		= "Desplazamiento + Longitud > Tamaño de archivo no permitido";
string EM_Assertion_failed			= "Error de aserción";
// Defines:
string EM_Illegal_define_name 		= "Nombre de la Definición no permitido";
string EM_ReplaceDefines			= "Reemplaz Definición";
string EM_Redefinition_multiparamet = "No se permite la redefinición de multiparámetros";
string EM_Cant_undef_a_define_with  = "No se puede desdefinir una definición con argumentos";
// Page:
string EM_Illegal_pagenumber		= "Número de página ilegal";
string EM_Invalid_pagerange			= "Rango de página no válido";
string EM_Page_already_exists		= "La página ya existe";
string EM_Page_does_not_exist		= "La página no existe";
string EM_Unknown_multipagemode		= "Modo multipágina desconocido";
// Module:
string EM_ENDMODULE_without_MODULE	= "ENDMODULE sin MODULE";
string EM_MODULE_not_found			= "MODULE no encontrado";
// BUCLES IF ELSE WHILE:
string EM_IF_without_ENDIF			= "IF sin ENDIF";
string EM_ELSEIF_without_IF			= "ELSEIF sin IF";
string EM_ELSEIF_within_ELSE		= "ELSEIF dentro ELSE";
string EM_ELSE_without_IF			= "ELSE sin IF";
string EM_ELSE_within_ELSE			= "ELSE dentro ELSE";
string EM_ENDIF_without_IF			= "ENDIF sin IF";
string EM_ENDWHILE_without_WHILE	= "ENDWHILE sin WHILE";
string EM_ENDREPEAT_without_REPEAT	= "ENDREPEAT sin REPEAT";
string EM_BREAK_used_outside_loop	= "BREAK usado fuera de un bucle";
string EM_CONTINUE_outside_loop		= "CONTINUE usado fuera de un bucle";
string EM_Negative_repeat_value		= "Valor de repetición negativo";
string EM_Negative_repeat_count		= "Número de repetición negativo";
string EM_Nothing_to_repeat			= "Nada que repetir";
string EM_without_repeatblock		= "% sin bloque de repetición";
// CODE / MAP / PHASE:
string EM_CODE_not_allowed_in_PHASE = "CODE no permitido en bloque PHASE";
string EM_ENDMAP_without_MAP		= "ENDMAP sin MAP";
string EM_PHASE_without_PHASE		= "PHASE sin DEPHASE";
string EM_DEPHASE_without_PHASE		= "DEPHASE sin PHASE";
// File:
string EM_Error_opening_file 		= "Error al abrir el archivo";
string EM_Write_error				= "Error de escritura";
string EM_Unexpected_end_of_file 	= "Inesperado final de archivo";
string EM_No_inputfile				= "Sin archivo de entrada";

#else


// Generic:
string EM_Syntax_error				= "Syntax error";
string EM_Overflow					= "Overflow";
string EM_Hoppa_Noppa				= "Hoppa? Noppa!";
string EM_Illegal_operand			= "Illegal operand";
string EM_Illegal_parameter			= "Illegal parameter";
string EM_Illegal_range				= "Illegal range";
string EM_Unknown_instruction		= "Unknown instruction";
string EM_Forward_reference			= "Forward reference";
string EM_Expression_expected		= "Expression expected";
string EM_Parameter_missing			= "Parameter missing";
string EM_Operand_expected 			= "Operand expected";
string EM_Division_by_zero 			= "Division by zero\n";
// Size:
string EM_Too_much_data 			= "Too much data";
string EM_Negative_size				= "Negative size";
string EM_Size_expected				= "Size expected";
string EM_Size_already_set			= "Size already set";
string EM_Maximum_part_size_256		= "Maximum part size (256) exceeded";
string EM_Part_does_not_fit			= "Part does not fit";
// Logic:
string EM_Unexpected				= "Unexpected";
string EM_Base_expected				= "Base expected";
string EM_Increment_expected		= "Increment expected";
string EM_Cannot_negate_condition	= "Cannot negate condition";
string EM_Negative_origin			= "Negative origin";
string EM_Digit_not_in_base			= "Digit not in base";
string EM_No_default_allowed 		= "No default allowed!";
string EM_No_greedy_stars_allowed	= "No greedy stars allowed!";
// Closing:
string EM_No_closing_B				= "No closing '\"'";
string EM_No_closing_R 				= "No closing '>'";
string EM_Closing_P_expected 		= "Closing ) expected";
string EM_Closing_C_expected 		= "Closing ] expected";
// Value / Target:
string EM_Default_value_expected	= "Default value expected";
string EM_Value_out_of_range		= "Value out of range";
string EM_Target_out_of_range		= "Target out of range (";
// Over:
string EM_Overlay_code_part_needs	= "Overlay code part needs a address";
string EM_Overlapping_routines		= "Overlapping routines";
string EM_Overloading_not_allowed 	= "Overloading not allowed";
// String:
string EM_String_expected			= "String expected";
string EM_Unexpected_end_of_string	= "Unexpected end of string";
string EM_Empty_string_not_allowed	= "Empty string not allowed";
string EM_Constant_expected 		= "Constant expected";
// Chars:
string EM_Illegal_character			= "Illegal character(s)";
string EM_Character_range_expected	= "Character(range) expected";
string EM_Comma_expected 			= "Comma expected";
string EM_Unknown_escape 			= "Unknown escape";
// Label:
string EM_Illegal_label_name		= "Illegal label name";
string EM_Label_not_found			= "Label not found";
string EM_Duplicate_labelname		= "Duplicate labelname";
string EM_Label_already_exists 		= "Label already exists";
string EM_Mixing_set_normal_labels  = "Mixing of set and normal labels not allowed";
string EM_Numberlabels_only_allowed = "Numberlabels only allowed as adresslabels";
// Macro:
string EM_Illegal_macroname 		= "Illegal macroname";
string EM_Illegal_macro_definition	= "Illegal macro definition";
string EM_Macro_already_exists 		= "Macro already exists";
string EM_Indirection_not_allowed	= "Indirection not allowed";
string EM_Use_rotate_outside_macro	= "Use of rotate not allowed outside macro";
string EM_Use_num_outside_macro		= "Use of @num not allowed outside macro";
string EM_Use_num_outside_loops		= "Use of @# not allowed outside loops";
string EM_ENDMACRO_without_MACRO	= "ENDMACRO without MACRO";
string EM_EXITMACRO_outside_macro	= "EXITMACRO used outside macro";
string EM_XEXITMACRO_outside_macro	= "XEXITMACRO used outside macro";
// Struct:
string EM_Illegal_structure_name	= "Illegal structure name";
string EM_Label_structure_not_found = "Label defined by structure not found?";
string EM_Structure_already_exists	= "Structure already exists";
string EM_ENDSTRUCT_without_STRUCT	= "ENDSTRUCT without STRUCT";
// Offest / Address / Align:
string EM_Invalid_addressrange		= "Invalid addressrange";
string EM_Illegal_addressmode		= "Illegal addressmode :)";
string EM_Illegal_alignment			= "Illegal alignment";
string EM_Offset_expected			= "Offset expected";
string EM_Offsets_not_allowed_jumps = "Offsets not allowed with jumps";
string EM_Offset_out_of_range		= "Offset out of range";
string EM_Alignment_expected		= "Alignment expected";
string EM_Alignment_value_expected	= "Alignment value expected";
string EM_Alignment_shouldbepositiv = "Alignment should be positive";
string EM_Unknown_alignmode			= "Unknown alignmode";
string EM_Negative_zero_alignment	= "Negative or zero alignment not allowed";
string EM_Negative_block_notallowed = "Negative block not allowed";
string EM_Negative_offsetnotallowed = "Negative offset is not allowed";
string EM_Negative_lengthnotallowed = "Negative length is not allowed";
string EM_file_size_not_allowed		= "offset+length>file size not allowed";
string EM_Assertion_failed			= "Assertion failed";
// Defines:
string EM_Illegal_define_name 		= "Illegal define name";
string EM_ReplaceDefines			= "ReplaceDefines";
string EM_Redefinition_multiparamet = "Redefinition of multiparameter define not allowed";
string EM_Cant_undef_a_define_with  = "Can't undef a define with arguments";
// Page:
string EM_Illegal_pagenumber		= "Illegal pagenumber";
string EM_Invalid_pagerange			= "Invalid pagerange";
string EM_Page_already_exists		= "Page already exists";
string EM_Page_does_not_exist		= "Page does not exist";
string EM_Unknown_multipagemode		= "Unknown multipagemode";
// Module:
string EM_ENDMODULE_without_MODULE	= "ENDMODULE without MODULE";
string EM_MODULE_not_found			= "MODULE not found";
// BUCLES IF ELSE WHILE:
string EM_IF_without_ENDIF			= "IF without ENDIF";
string EM_ELSEIF_without_IF			= "ELSEIF without IF";
string EM_ELSEIF_within_ELSE		= "ELSEIF within ELSE";
string EM_ELSE_without_IF			= "ELSE without IF";
string EM_ELSE_within_ELSE			= "ELSE within ELSE";
string EM_ENDIF_without_IF			= "ENDIF without IF";
string EM_ENDWHILE_without_WHILE	= "ENDWHILE without WHILE";
string EM_ENDREPEAT_without_REPEAT	= "ENDREPEAT without REPEAT";
string EM_BREAK_used_outside_loop	= "BREAK used outside loop";
string EM_CONTINUE_outside_loop		= "CONTINUE used outside loop";
string EM_Negative_repeat_value		= "Negative repeat value";
string EM_Negative_repeat_count		= "Negative repeat count";
string EM_Nothing_to_repeat			= "Nothing to repeat";
string EM_without_repeatblock		= "% without repeatblock";
// CODE / MAP / PHASE:
string EM_CODE_not_allowed_in_PHASE = "CODE not allowed in PHASE block";
string EM_ENDMAP_without_MAP		= "ENDMAP without MAP";
string EM_PHASE_without_PHASE		= "PHASE without DEPHASE";
string EM_DEPHASE_without_PHASE		= "DEPHASE without PHASE";
// File:
string EM_Error_opening_file 		= "Error opening file";
string EM_Write_error				= "Write error";
string EM_Unexpected_end_of_file 	= "Unexpected end of file";
string EM_No_inputfile				= "No inputfile";
#endif
*/

ErrorTable errtab;
int lasterror=-1;

void error( int line, int listline, string e, string a, int i ) {
	if (i==ERRREP && lasterror==listline) return;

	again=0;
	lasterror=listline;
	string msg;

//if (!listopt._macroname.empty()) {
//	msg="from "+listopt._macroname;
//	if (listopt._macrofilename!=listopt._filename) msg+=" in "+listopt._macrofilename;
//	if (listopt._macrocurlin) msg+=" line "+tostr(listopt._macrocurlin);
//	errtab.add(listline,msg,i);
//}

//if (line) msg=listopt._filename+" line "+tostr(line)+": "+e; else msg=e;
//if (!a.empty()) msg+=": "+a;
//if (errtab.add(listline,msg,i)) ++errors;

	if (line) msg=listopt._filename+"("+tostr(line)+") : "+e; else msg=e;
	if (!a.empty()) msg+=": "+a;
	if (errtab.add(listline,msg,i)) ++errors;

	if (!listopt._macroname.empty()) {
		msg= "\t" + listopt._macrofilename + "(" +
			tostr( listopt._macrocurlin ) + TXT_see + listopt._macroname;
		errtab.add(listline,msg,i);
	}

	if (i==ERRFATAL || i==ERRINTERNAL) {
		cout << msg << endl;
#ifdef _DEBUG
#ifdef SPANISH
		cout << "ERROR FATAL - PULSA INTRO" << endl;
#else
		cout << "FATAL ERROR - PRESS ENTER" << endl;
#endif
		cin.get();
#endif
		exit(1);
	}
}

void error( string e, string a, int i ) { error(curlin,listcurlin,e,a,i); }
void error( string e, int i ) { error(curlin,listcurlin,e,"",i); }
void error1( string e, string a, int i ) { error(curlin,listcurlin,e,a,i); }
void error1( string e, int i ) { error(curlin,listcurlin,e,"",i); }

void errorvalue() { errorvalue( EM_Value_out_of_range ); }

void errorvalue( string n_msg ) {
	if (again && !lpass) return;
	error(n_msg,ERRNORMAL);
}

void errortarget( string n_msg ) {
	if (!lpass || errors) { again=1; return; }
	int oerrors=errors;
	error(n_msg,ERRNORMAL);
	if (oerrors!=errors) { --errors; ++adrerrors; }
}

void errortarget( int n_offset ) {
	errortarget( EM_Target_out_of_range + tostr( n_offset ) + ")" );
}

int ErrorTable::add( int n_line, string n_msg, int n_type ) {
	if (_nextlocation>=_size*2/3) _grow();
	int tr,htr;
	tr=_hash(n_line);
	while( (htr=_hashtable[tr]) ) {
		if(	_errtab[htr]._line==n_line &&
			( pass>2 || _errtab[htr]._msg==n_msg )
		) return 0;
		if (++tr>=_size) tr=0;
	}
	_hashtable[tr]=_nextlocation;
	_errtab[_nextlocation]._line=n_line;
	_errtab[_nextlocation]._msg=n_msg;
	_errtab[_nextlocation]._type=n_type;
	++_nextlocation;
	return 1;
}

void ErrorTable::geterrors( int linenr, StringList &list ) {
	int e,p=_hash(linenr);
	while ( (e=_hashtable[p] ) )  {
		if (_errtab[e]._line==linenr) {
			cout << _errtab[e]._msg << endl;
			list.push_back(_errtab[e]._msg);
		}
		if (++p>=_size) p=0;
	}
}

void ErrorTable::_grow() {
	int tr;
	_size=_size*2+1;
	_hashtable.clear();
	_hashtable.resize( _size );
	_errtab.resize( _size );
	for (int i=1;i!=_nextlocation;++i) {
		tr=_hash( _errtab[i]._line );
		while( _hashtable[tr] ) if( ++tr>=_size ) tr=0;
		_hashtable[tr]=i;
	}
}

//eof

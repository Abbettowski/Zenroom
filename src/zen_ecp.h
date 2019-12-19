/* This file is part of Zenroom (https://zenroom.dyne.org)
 *
 * Copyright (C) 2017-2019 Dyne.org foundation
 * designed, written and maintained by Denis Roio <jaromil@dyne.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 */

#ifndef __ZEN_ECP_H__
#define __ZEN_ECP_H__

// should abstract this away
// #include <fp12_BLS12383.h>
#include <ecp2_BLS12383.h>
#include <ecp_BLS12383.h>
#define ECP ECP_BLS12383
#define ECP2 ECP2_BLS12383
// #pragma message "BIGnum CHUNK size: 32bit"
#include <big_384_29.h>
#define  BIG  BIG_384_29

typedef struct {
	char curve[16];
	char type[16];
	int  biglen; // length in bytes of a reduced coordinate
	int  totlen; // length of a serialized octet

	BIG  order;
	ECP  val;
	// TODO: the values above make it necessary to propagate the
	// visibility on the specific curve point types to the rest of the
	// code. To abstract these and have get/set functions may save a
	// lot of boilerplate when implementing support for multiple
	// curves ECP.
} ecp;

ecp* ecp_new(lua_State *L);
ecp* ecp_arg(lua_State *L,int n);

typedef struct {
	char curve[16];
	char type[16];
	int totlen;
	BIG  order;
	ECP2  val;
	// TODO: the values above make it necessary to propagate the
	// visibility on the specific curve point types to the rest of the
	// code. To abstract these and have get/set functions may save a
	// lot of boilerplate when implementing support for multiple
	// curves ECP.
} ecp2;

#endif

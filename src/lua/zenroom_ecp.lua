-- This file is part of Zenroom (https://zenroom.dyne.org)
--
-- Copyright (C) 2018-2019 Dyne.org foundation
-- designed, written and maintained by Denis Roio <jaromil@dyne.org>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local ecp = require'ecp'

function ecp.hashtopoint(s)
   return ecp.mapit(sha512(s))
end

function ecp.random()
   return ecp.mapit(OCTET.random(64))
end

function ecp.prime()
   -- TODO: retrieve from milagro's ROM, hardcoded now for BLS383
   return BIG.new( OCTET.from_hex('5565569564AB6EB5A06DADC41FEA9284A0AD462CF365A511AC31B801696124F47A8C3F298A64852BDA371D6485AAB0AB') )
end

return ecp

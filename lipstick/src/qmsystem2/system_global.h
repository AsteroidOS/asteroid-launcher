/*!
 * @file system_global.h
 * @brief System macros.

   <p>
   @copyright (C) 2009-2011 Nokia Corporation
   @license LGPL Lesser General Public License

   @author Antonio Aloisio <antonio.aloisio@nokia.com>
   @author Ilya Dogolazky <ilya.dogolazky@nokia.com>
   @author Raimo Vuonnala <raimo.vuonnala@nokia.com>
   @author Sagar Shinde <ext-sagar.shinde@nokia.com>
   @author Timo Olkkonen <ext-timo.p.olkkonen@nokia.com>
   @author Timo Rongas <ext-timo.rongas.nokia.com>

   @scope Private

   This file is part of SystemSW QtAPI.

   SystemSW QtAPI is free software; you can redistribute it and/or modify
   it under the terms of the GNU Lesser General Public License
   version 2.1 as published by the Free Software Foundation.

   SystemSW QtAPI is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with SystemSW QtAPI.  If not, see <http://www.gnu.org/licenses/>.
   </p>
 */
#ifndef SYSTEM_GLOBAL_H
#define SYSTEM_GLOBAL_H
#include <QtCore/qglobal.h>

//MEEGO MOBILITY SYSTEM PRIVATE IMPLEMENTATION
#define MEEGO_DECLARE_PRIVATE(Class) \
        private: \
                inline Class##Private* priv_func() { return reinterpret_cast<Class##Private *>(priv_ptr); } \
                inline const Class##Private* priv_func() const { return reinterpret_cast<const Class##Private *>(priv_ptr); } \
                friend class Class##Private; \
                void* priv_ptr;

#define MEEGO_DECLARE_PROTECTED(Class) \
        protected: \
                inline Class##Private* priv_func() { return reinterpret_cast<Class##Private *>(priv_ptr); } \
                inline const Class##Private* priv_func() const { return reinterpret_cast<const Class##Private *>(priv_ptr); } \
                friend class Class##Private; \
                void* priv_ptr;

#define MEEGO_DECLARE_PUBLIC(Class) \
        public: \
                inline Class* pub_func() { return static_cast<Class *>(pub_ptr); } \
                inline const Class* pub_func() const { return static_cast<const Class *>(pub_ptr); } \
        private: \
                friend class Class; \
                void* pub_ptr;

#define MEEGO_PRIVATE(Class) Class##Private * const priv = priv_func();
#define MEEGO_PRIVATE_CONST(Class) const Class##Private * const priv = priv_func();
#define MEEGO_PUBLIC(Class) Class * const pub = pub_func();

#define MEEGO_INITIALIZE(Class) \
                priv_ptr = new Class##Private(); \
                MEEGO_PRIVATE(Class); \
                priv->pub_ptr = this;

#define MEEGO_UNINITIALIZE(Class) do { MEEGO_PRIVATE(Class); delete priv; } while(0)

#endif // SYSTEM_GLOBAL_H

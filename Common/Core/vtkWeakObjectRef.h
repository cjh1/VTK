/*=========================================================================

  Program:   Visualization Toolkit
  Module:    vtkArray.h

-------------------------------------------------------------------------
  Copyright 2008 Sandia Corporation.
  Under the terms of Contract DE-AC04-94AL85000 with Sandia Corporation,
  the U.S. Government retains certain rights in this software.
-------------------------------------------------------------------------

  Copyright (c) Ken Martin, Will Schroeder, Bill Lorensen
  All rights reserved.
  See Copyright.txt or http://www.kitware.com/Copyright.htm for details.

     This software is distributed WITHOUT ANY WARRANTY; without even
     the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
     PURPOSE.  See the above copyright notice for more information.

=========================================================================*/

/**
 * @class   vtkArray
 * @brief   Abstract interface for N-dimensional arrays.
 *
 *
 * vtkArray is the root of a hierarchy of arrays that can be used to
 * store data with any number of dimensions.  It provides an abstract
 * interface for retrieving and setting array attributes that are
 * independent of the type of values stored in the array - such as the
 * number of dimensions, extents along each dimension, and number of
 * values stored in the array.
 *
 * To get and set array values, the vtkTypedArray template class derives
 * from vtkArray and provides type-specific methods for retrieval and
 * update.
 *
 * Two concrete derivatives of vtkTypedArray are provided at the moment:
 * vtkDenseArray and vtkSparseArray, which provide dense and sparse
 * storage for arbitrary-dimension data, respectively.  Toolkit users
 * can create their own concrete derivatives that implement alternative
 * storage strategies, such as compressed-sparse-row, etc.  You could
 * also create an array that provided read-only access to 'virtual' data,
 * such as an array that returned a Fibonacci sequence, etc.
 *
 * @sa
 * vtkTypedArray, vtkDenseArray, vtkSparseArray
 *
 * @par Thanks:
 * Developed by Timothy M. Shead (tshead@sandia.gov) at  Sandia National
 * Laboratories.
*/

#ifndef vtkWeakObjectRef_h
#define vtkWeakObjectRef_h

#include "vtkCommonCoreModule.h" // For export macro
#include "vtkObject.h"
#include "vtkWeakPointer.h"

class VTKCOMMONCORE_EXPORT vtkWeakObjectRef : public vtkObject
{
public:
  vtkTypeMacro(vtkWeakObjectRef, vtkObject);
  VTKCOMMONCORE_EXPORT static vtkWeakObjectRef *New();
  vtkWeakObjectRef();
  ~vtkWeakObjectRef();
  void PrintSelf(ostream &os, vtkIndent indent) VTK_OVERRIDE;
  void Set(vtkObject *obj);
  vtkObject* Get();

private:
  vtkWeakPointer<vtkObject> Obj;
};
  //@}

#endif

// VTK-HeaderTest-Exclude: vtkWeakPointer.h

Attribute VB_Name = "HelperFunctions"
' OSE - Oblivion Save Editor
' Copyright (C) 2012, 2013 Grahame White
'
' This program is free software; you can redistribute it and/or modify
' it under the terms of the GNU General Public License as published by
' the Free Software Foundation; either version 2 of the License, or
' (at your option) any later version.
'
' This program is distributed in the hope that it will be useful,
' but WITHOUT ANY WARRANTY; without even the implied warranty of
' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
' GNU General Public License for more details.
'
' You should have received a copy of the GNU General Public License along
' with this program; if not, write to the Free Software Foundation, Inc.,
' 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Option Explicit
DefObj A-Z

Public Function Ordinal(ByVal DayValue As Integer) As String

    Select Case DayValue
         Case 1, 21, 31
            Ordinal = DayValue & "st"
         Case 2, 22
            Ordinal = DayValue & "nd"
         Case 3, 23
            Ordinal = DayValue & "rd"
         Case Else
            Ordinal = DayValue & "th"
      End Select

End Function

Public Sub ValidateInput(ByRef CheckTextBox As TextBox, ByVal MinVal As Long, ByVal MaxVal As Long)
    
    If Not (IsNumeric(CheckTextBox.Text)) Then
        SendMessage CheckTextBox.hwnd, EM_UNDO, 0, ByVal 0&
        SendMessage CheckTextBox.hwnd, EM_EMPTYUNDOBUFFER, 0, ByVal 0&
    ElseIf CheckTextBox.Text < MinVal Or CheckTextBox.Text > MaxVal Then
        SendMessage CheckTextBox.hwnd, EM_UNDO, 0, ByVal 0&
        SendMessage CheckTextBox.hwnd, EM_EMPTYUNDOBUFFER, 0, ByVal 0&
    Else
        SendMessage CheckTextBox.hwnd, EM_EMPTYUNDOBUFFER, 0, ByVal 0&
        CheckTextBox.Text = Int(CheckTextBox.Text)
    End If

End Sub

Public Function GetFormID(ByVal iRef As Long) As Long

    If iRef < 0 Then
        GetFormID = iRef
        Exit Function
    End If

    If iRef < SaveFileData.FormIDs.NumberOfFormIDs Then
        GetFormID = SaveFileData.FormIDs.FormIDsList(iRef)
    End If

End Function

Public Function GetIref(ByVal FormID As Long) As Long

    Dim i As Integer
    
    For i = 0 To SaveFileData.FormIDs.NumberOfFormIDs - 1
        If FormID = SaveFileData.FormIDs.FormIDsList(i) Then
            GetIref = i
            Exit Function
        End If
    Next i

    GetIref = -1

End Function

Public Function GetModIndex(ByVal ModName As String) As LongType

    Dim i As Integer
    Dim Index As FourByteArray
    
    For i = 0 To SaveFileData.PlugIns.NumberOfPlugins - 1
        If ModName = SaveFileData.PlugIns.PlugInNames(i) Then
            Index.Bytes(3) = i
            Exit For
        End If
    Next i

    LSet GetModIndex = Index

End Function

Public Function GetSpecialFolder(ByVal CSIDL As Long, ByRef Owner As Form) As String
        
    Dim Path As String
    Dim IDL As ITEMIDLIST
    '
    ' Retrieve info about system folders such as the "Recent Documents" folder.
    ' Info is stored in the IDL structure.
    '
    GetSpecialFolder = ""
    If SHGetSpecialFolderLocation(Owner.hwnd, CSIDL, IDL) = 0 Then
        '
        ' Get the path from the ID list, and return the folder.
        '
        Path = Space(MAX_PATH)
        If SHGetPathFromIDList(ByVal IDL.mkid.cb, ByVal Path) Then
            GetSpecialFolder = VBA.Left(Path, InStr(Path, vbNullChar) - 1) & ""
        End If
    End If
        
End Function

Public Function GetType(ByRef DataBlock() As Byte, ByRef Offset As Integer) As String

    Dim i As Integer

    For i = 0 To 3
        GetType = GetType & Chr$(DataBlock(Offset + i))
    Next i

    Offset = Offset + 4

End Function

Public Function GetZString(ByRef DataBlock() As Byte, ByRef Offset As Integer) As String

    Do Until DataBlock(Offset) = &H0
        GetZString = GetZString & Chr$(DataBlock(Offset))
        Offset = Offset + 1
    Loop

End Function

Public Function GetInteger(ByRef DataBlock() As Byte, ByRef Offset As Integer) As Integer

    GetInteger = DataBlock(Offset)
    GetInteger = GetInteger + (DataBlock(Offset + 1) * BYTE_2)

    Offset = Offset + 2

End Function

namespace System.Security.AccessControl;

using Microsoft.Utility.ImageAnalysis;
using System.Security.AccessControl;

permissionsetextension 31135 "D365 BASICImage Analyzer" extends "D365 BASIC"
{
    Permissions = tabledata "MS - Image Analyzer Tags" = RIMD,
                  tabledata "MS - Img. Analyzer Blacklist" = RIMD;
}

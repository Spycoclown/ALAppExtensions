namespace System.Security.AccessControl;

using Microsoft.Utility.ImageAnalysis;
using System.Security.AccessControl;

permissionsetextension 9453 "D365 BUS PREMIUMImage Analyzer" extends "D365 BUS PREMIUM"
{
    Permissions = tabledata "MS - Image Analyzer Tags" = RIMD,
                  tabledata "MS - Img. Analyzer Blacklist" = RIMD;
}

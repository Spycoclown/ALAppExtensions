// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135135 "Image Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Image: Codeunit Image;
        Assert: Codeunit "Library Assert";
        Base64Convert: Codeunit "Base64 Convert";
        ImageAsBase64Txt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAOSURBVChTYxgFJAMGBgABNgABY8OiGAAAAABJRU5ErkJggg==';
        ImageInvalidTxt: Label 'CjwvZz4KPC9zdmc+Cg==';

    [Test]
    procedure CreateImageFromStreamTest()
    var
        ImageBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Given] A Base64 encoded image convert it to a stream
        ImageBlob.CreateOutStream(OutStream);
        Base64Convert.FromBase64(ImageAsBase64Txt, OutStream);
        ImageBlob.CreateInStream(InStream);

        // [When] Reads valid stream data
        ClearLastError();
        Image.FromStream(InStream);

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure CreateImageFromBase64Test()
    begin
        // [Given] base64 encoded data create image 
        ClearLastError();
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure FailToCreateImageTest()
    var
        ImageBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        InStream: InStream;
    begin
        // [Given] A invalid image convert it to a stream. 
        ImageBlob.CreateOutStream(OutStream);
        OutStream.Write(ImageInvalidTxt);
        ImageBlob.CreateInStream(InStream);

        // [Then] Read stream and fail as image data is invalid
        asserterror Image.FromStream(InStream);
        Assert.ExpectedError('Image is not in valid format');
    end;

    [Test]
    procedure FailToCreateBase64ImageTest()
    begin
        // [Given] bad base64 encoded data, fail to create image 
        asserterror Image.FromBase64(ImageInvalidTxt);
        Assert.ExpectedError('Image is not in valid format');
    end;

    [Test]
    procedure ConvertToBase64Test()
    var
        Base64Text: Text;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] decode image back to base64 without any errors
        // Note: The encoding is not the same each time, and that is why we dont compare it to the input
        ClearLastError();
        Base64Text := Image.ToBase64();

        // [Then] verify no error occurred
        Assert.AreEqual('', GetLastErrorText(), 'No error should have occurred');
    end;

    [Test]
    procedure GetFormatTest()
    var
        Format: Enum "Image Format";
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify format
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');
    end;

    [Test]
    procedure GetFormatAsTextTest()
    var
        FormatText: Text;
    begin
        // [Given] base64 encoded data, create image
        FormatText := 'Png';
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify string formatted format
        Assert.AreEqual(FormatText, Image.GetFormatAsText(), 'Format failed');
    end;

    [Test]
    procedure GetDimensionsTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] verify dimensions
        Assert.AreEqual(10, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(10, Image.GetHeight(), 'Incorrect height');
    end;

    [Test]
    procedure ClearTest()
    var
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        ImageAsBase64ClearTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAIAAAACUFjqAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAOwgAADsIBFShKgAAAACNJREFUKFN9x7ENAAAIwKD+/7TOMpiw0PTx8PDw8PDw8PBHLbfKY51z/cP9AAAAAElFTkSuQmCC', Locked = true;
        CurrentWidth, CurrentHeight : Integer;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] clearing image
        Image.Clear(255, 0, 0);

        // [Then] verify image
        Assert.AreEqual(CurrentWidth, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(CurrentHeight, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(ImageAsBase64ClearTxt, Image.ToBase64(), 'Clear failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidClearTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] Fail to do invalid resizing 
        asserterror Image.Clear(-1, 0, 0);
        Assert.ExpectedError('Parameter Red must be between 0 and 255');
    end;

    [Test]
    procedure ResizeTest()
    var
        TempBlob: Codeunit "Temp Blob";
        Format: Enum "Image Format";
        OutStream: OutStream;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] resizing image
        Image.Resize(5, 5);

        // [Then] verify dimensions and format
        Assert.AreEqual(5, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(5, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidResizeTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] Fail to do invalid resizing 
        asserterror Image.Resize(-1, 5);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

    [Test]
    procedure RotateFlipTest()
    var
        TempBlob: Codeunit "Temp Blob";
        RotateFlipType: Enum "Rotate Flip Type";
        OutStream: OutStream;
        ImageAsBase64HorizontalTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAIAAADzBuo/AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAEnQAABJ0Ad5mH3gAAAAUSURBVBhXY6AS+P//PxqDQsDAAADP2QX7LebCcQAAAABJRU5ErkJggg==', Locked = true;
        ImageAsBase64VerticalTxt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAUAAAAKCAIAAADzWwNnAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAScwAAEnMBjCK5BwAAABdJREFUGFdjIA/8//8fyiIOkKoeChgYAN7PBfvkP6CNAAAAAElFTkSuQmCCAABJRU5ErkJggg==', Locked = true;
        CurrentWidth, CurrentHeight : Integer;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64HorizontalTxt);
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] rotate image
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);

        // [Then] verify image
        Assert.AreEqual(CurrentHeight, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(CurrentWidth, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(ImageAsBase64VerticalTxt, Image.ToBase64(), 'RotateFlip failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure RotateFlip360Test()
    var
        TempBlob: Codeunit "Temp Blob";
        RotateFlipType: Enum "Rotate Flip Type";
        OutStream: OutStream;
        CurrentWidth, CurrentHeight : Integer;
        Original, Rotated : Text;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);
        CurrentWidth := Image.GetWidth();
        CurrentHeight := Image.GetHeight();

        // [When] rotate image 360 degrees
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Original := Image.ToBase64();

        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);
        Image.RotateFlip(RotateFlipType::Rotate90FlipNone);

        Rotated := Image.ToBase64();

        // [Then] verify image
        Assert.AreEqual(CurrentHeight, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(CurrentWidth, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(Original, Rotated, 'RotateFlip failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure CropTest()
    var
        TempBlob: Codeunit "Temp Blob";
        Format: Enum "Image Format";
        OutStream: OutStream;
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [When] cropping image
        Image.Crop(5, 5, 5, 5);

        // [Then] verify dimensions and format
        Assert.AreEqual(5, Image.GetWidth(), 'Incorrect width');
        Assert.AreEqual(5, Image.GetHeight(), 'Incorrect height');
        Assert.AreEqual(Format::Png, Image.GetFormat(), 'Format failed');

        // [Then] save to stream
        TempBlob.CreateOutStream(OutStream);
        Image.Save(OutStream);
        Assert.AreNotEqual(0, TempBlob.Length(), 'Image was not saved');
    end;

    [Test]
    procedure InvalidCropTest()
    begin
        // [Given] base64 encoded data, create image
        Image.FromBase64(ImageAsBase64Txt);

        // [Then] fail cropping image with invalid parameters
        asserterror Image.Crop(0, 0, 0, 0);
        Assert.ExpectedError('Parameter Width must be greater than 0');
    end;

}
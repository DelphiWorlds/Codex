object AndroidResources: TAndroidResources
  Height = 132
  Width = 494
  object ActionList: TActionList
    Images = VirtualImageList
    Left = 260
    Top = 20
    object ADBConnectAction: TAction
      Hint = 'ADB connect an Android device via IP'
      ImageIndex = 0
      ImageName = 'Item1'
    end
  end
  object VirtualImageList: TVirtualImageList
    Images = <
      item
        CollectionIndex = 0
        CollectionName = 'Item1'
        Name = 'Item1'
      end>
    ImageCollection = ImageCollection
    Left = 44
    Top = 20
  end
  object ImageCollection: TImageCollection
    Images = <
      item
        Name = 'Item1'
        SourceImages = <
          item
            Image.Data = {
              89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
              61000001674944415478DA63FCFFFF3F033AD8FFB8A6435DC06FFD83CF079C40
              7C055EC7BD37DF6F0A74946BAE4457CB886EC0FFFF7F99D7DC8A5877FBC3663F
              64717541FF75416ACB43191998FEE135E0C4F3BEB27D8FAA3AE3B50E5A2DBC66
              7F0C2406645B02D9C79DE5BA8ACD25F3FAF01A30F59CE6DD8FBFEF2B31600182
              1C4A7733F5AFA96018F0F5F76BB14BAF1726E98BC4CF3DFF664EFAFF7FFF98B0
              19C0C8C4F4CF403469F645A05A0391C4395C6CA2AFC1061C7BD65975E0717DAB
              836C63358866C003EC651A6A0E3E696801A9B5922A6F031B70F8494BC3E1A72D
              F5B6D2358D201A9F01303520DA56A6A6619018000B0347D9964A60226AC76700
              2C9C406A2DA54A3AC0067CFFFD4EE8CADB65B1BA22D18BFACE4ABEC36740A1D1
              3361985A0E16C1F718E9A0ED24C77F7C065499FF60C44807C8E0E893F69A834F
              1B9BC151265D5F0BA291F9D632952D780D407605CC36743EED0D5878D5F10833
              23F3DF18AD3DF6D8F8C80000DC4BFDE1B44AA6BE0000000049454E44AE426082}
          end>
      end>
    Left = 156
    Top = 20
  end
  object APKFolderOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select folder to extract APKs to'
    Left = 360
    Top = 20
  end
end

require 'reseed/step'

class TFSStep < Step
  TfsPath = 'c:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\TF.exe'

  attr_accessor :files
end

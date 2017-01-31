-- Everyone's favorite Torch imports
require 'nn';
require 'cutorch';
Dataset = require 'dataset.Dataset';
torch.setdefaulttensortype('torch.FloatTensor');

-- Data prep
local csds = Dataset("/media/tom/shared/remote_index.csv")
local getBatch, numBatches = csds.sampledBatcher({
      batchSize = 8,
      inputDims = {3,200,200},
      samplerKind = 'permutation',
      get = getFile,
      verbose = true,
      processor = function(res, processorOpt, input)
              --return function(res, processorOpt, input)
              -- This code is from the torch-dataset repo on git, curtosy the Twitter team
              -- However, I attempted to turn the function into a closure (I'm led to believe it'll run faster)
              -- Turn the res string into a ByteTensor (containing the PNG file's contents)
              local image = require 'image';
              local bytes = torch.ByteTensor(#res)
              bytes:storage():string(res)
              -- Decompress the PNG bytes into a Tensor
              local pixels = image.decompressPNG(bytes)
              -- Copy the pixels tensor into the mini-batch
              input:copy(pixels)
              return true
             --end
      end,
   })


-- Model prep
local cs_learn = nn.Sequential()
cs_learn:add(nn.SpatialConvolution(3,4,100,100))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(4,16,50,50))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(16,64,10,10))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.View(64*10*10))
cs_learn:add(nn.Linear(64*10*10,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.Sigmoid())
--torch.save('cs_learn_model.t7', cs_learn)
-- Training and Testing
local criterion = nn.BCECriterion()
local b = 1
while b <= 1 do
    local batch = getBatch()
    
end
--torch.save('cs_learn_model.t7', cs_learn)
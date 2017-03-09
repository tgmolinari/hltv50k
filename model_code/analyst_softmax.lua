-- Everyone's favorite Torch imports
require 'nn';
require 'optim';
require 'cutorch';
local sys = require 'sys';
Dataset = require 'dataset.Dataset';
torch.setdefaulttensortype('torch.FloatTensor');
-- Data prep
local csds = Dataset("ftrain.csv")
-- faze_imt_T_14_23_7_24.png
-- Source of the two image swatches

-- 2793
-- 2589 CT rounds in test
-- 27041
-- 23773 CT rounds in train

function trainModel(model, epochs)
    --local params, grad_params = model:getParameters()
    local classBalance = torch.FloatTensor(2)
    classBalance[1] = 1 -.53057132 -- portion of T
    classBalance[2] = .53057132 -- portion CT
    --local image = require 'image';
    local criterion = nn.ClassNLLCriterion(classBalance)
    local optimConfig = {learningRate = .001, momentum = .5, weightDecay = 1e-3}

    local e = 1
    while e <= epochs do
      local sum_loss = 0
      local getBatch, numBatches = csds.sampledBatcher({
            batchSize = 8,
            inputDims = {5,200,200},
            samplerKind = 'permutation',
            verbose = true,
            processor = function(res, processorOpt, input)
                    --return function(res, processorOpt, input)
                    -- This code is from the torch-dataset repo on git, curtosy the Twitter team
                    -- However, I attempted to turn the function into a closure (I'm led to believe it'll run faster)
                    -- Turn the res string into a ByteTensor (containing the PNG file's contents)
                    
                    local image = require 'image';
                    local bytes = torch.ByteTensor(#res)
                    local ctp = image.load("ct_patch.png")
                    local tp = image.load("t_patch.png")
                    bytes:storage():string(res)
                    -- Decompress the PNG bytes into a Tensor
                    local pixels = image.decompressPNG(bytes)
                    local fim = image.convolve(pixels, ctp, 'same')
                    local fim2 = image.convolve(pixels, tp, 'same')
                    fim = fim[{{1}, {}, {}}] + fim[{{2}, {}, {}}] + fim[{{3}, {}, {}}] / 3
                    fim2 = fim2[{{1}, {}, {}}] + fim2[{{2}, {}, {}}] + fim2[{{3}, {}, {}}] / 3

                    --print(fim2)
                    -- Copy the pixels tensor into the mini-batch
                    local temp1 = torch.cat(pixels,fim,1)
                    local temp2 = torch.cat(temp1,fim2,1)
                    input:copy(temp2)
                    return true
            end,
         })
      local im_count = 0
      local b = 1
      print("Total batches: " .. numBatches())
      local params, gradParams = model:getParameters()
      model:training()
      while b <= numBatches() do
          collectgarbage()
          print("ON BATCH #" .. b)
          function feval(params)
            local batch = getBatch()
            local preds = model:forward(batch['input'])
            local labels = batch['target']
            local loss = criterion:forward(preds,labels)
            gradParams:zero()
            local gradOutputs = criterion:backward(preds,labels)
            model:backward(batch['input'], gradOutputs)
            sum_loss = sum_loss + loss
            im_count = b*8
            --print("BATCH #" .. b .. " || Avg loss " .. sum_loss/im_count)
            return loss, gradParams
          end
          optim.sgd(feval,params,optimConfig)
          b = b + 1
      end
      print("END OF EPOCH " .. e)
      e = e + 1
    end
end


-- Model prep
local cs_learn = nn.Sequential()
cs_learn:add(nn.SpatialConvolution(5,16,8,8))
cs_learn:add(nn.SpatialBatchNormalization(16, 1e-3))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(16,32,4,4))
cs_learn:add(nn.SpatialBatchNormalization(32, 1e-3))
--cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(32,64,2,2))
cs_learn:add(nn.SpatialBatchNormalization(64, 1e-3))
--cs_learn:add(nn.SpatialMaxPooling(2,2))
--cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.SpatialConvolution(64,128,2,2))
cs_learn:add(nn.SpatialBatchNormalization(128, 1e-3))
cs_learn:add(nn.SpatialMaxPooling(2,2))
cs_learn:add(nn.ReLU())
cs_learn:add(nn.View(128*94*94))--Careful with vectorizing your inputs, as if you specify incorrectly the model won't care and it'll eat your lunch (it's the reason we only got 1 prediction when we based in a batch.)
cs_learn:add(nn.Linear(128*94*94,256))
cs_learn:add(nn.Linear(256,2))
cs_learn:add(nn.LogSoftMax())

-- Training


local t0 = sys.clock()
trainModel(cs_learn,3)
local dt = (sys.clock()-t0)
--torch.save('cs_learn_model_11.t7', cs_learn)
print("Total seconds to train " .. numBatches() .." batches of ~8 images)")
print(dt)

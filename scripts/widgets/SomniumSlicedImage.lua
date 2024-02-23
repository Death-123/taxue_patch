local SomniumWidget = require "widgets/SomniumWidget"
local SomniumImage = require "widgets/SomniumImage"

---@class SomniumSlicedImage:Widget
---@overload fun(textures:table):SomniumSlicedImage
---@field _ctor fun(self, textures:table)
---@field images table<integer,table>
---@field mode string
---| "'slice31'" sliced 3 * 1
---| "'slice13'" sliced 1 * 3
---| "'slice33'" sliced 3 * 3
---@field texScale number
---@field width integer
---@field height integer
local SomniumSlicedImage = Class(SomniumWidget, function(self, textures)
    SomniumWidget._ctor(self, "SomniumSlicedImage")
    self.images = {}
    self.mode = assert(textures.mode)
    self.atlas = assert(textures.atlas)
    self.texname = assert(textures.texname)
    self.texScale = textures.texScale or 1
    self.width = textures.width or 100
    self.height = textures.height or 100
    self:SetTextures(textures)
end)

---@return string
function SomniumSlicedImage:__tostring() return string.format("%s (%s)", self.name, self.mode) end

---删除存在的图像
---@return SomniumSlicedImage
function SomniumSlicedImage:RemoveImages()
    for _, image in pairs(self.images) do
        image:kill()
    end
    self.images = {}
    return self
end

---设置材质
---@param textures table
---@return SomniumSlicedImage
function SomniumSlicedImage:SetTextures(textures)
    self.mode = textures.mode or self.mode
    if self.mode == "slice13" or self.mode == "slice31" then
        self:RemoveImages()
        for i = 1, 3 do
            self.images[i] = self:AddChild(SomniumImage(textures.atlas, textures.texname .. "_" .. i .. ".tex"))
        end
        if self.mode == "slice13" then
            assert(self.images[1].originHeight == self.images[2].originHeight, "Height must be equal!")
            assert(self.images[1].originHeight == self.images[3].originHeight, "Height must be equal!")
        else
            assert(self.images[1].originWidth == self.images[2].originWidth, "Width must be equal!")
            assert(self.images[1].originWidth == self.images[3].originWidth, "Width must be equal!")
        end
    elseif self.mode == "slice33" then
        self:RemoveImages()
        for i = 1, 3 do
            for j = 1, 3 do
                local index = i * 10 + j
                self.images[index] = self:AddChild(SomniumImage(textures.atlas, textures.texname .. "_" .. index .. ".tex"))
                if i > 1 then assert(self.images[index].originWidth == self.images[index - 10].originWidth, "Width must be equal!") end
                if j > 1 then assert(self.images[index].originHeight == self.images[index - 1].originHeight, "Height must be equal!") end
            end
        end
    else
        error("Mode not supported!")
    end
    self:SetSize(textures.width, textures.height)
    return self
end

---设置大小
---@param width integer
---@param height integer
---@return SomniumSlicedImage
function SomniumSlicedImage:SetSize(width, height)
    width = width or self.width
    height = height or self.height
    if self.mode == "slice13" then
        local image1 = self.images[1]
        local image2 = self.images[2]
        local image3 = self.images[3]
        local texScale = math.min(self.texScale, math.min(width / (image1.originWidth + image3.originWidth), height / image1.originHeight))
        local w1 = math.floor(image1.originWidth * texScale)
        local w3 = math.floor(image3.originWidth * texScale)
        local w2 = math.max(0, width - w1 - w3)
        image1:SetSize(w1, height)
        image2:SetSize(w2, height)
        image3:SetSize(w3, height)
        local x2 = (w1 - w3) / 2
        local x1 = -w1 / 2 - w2 / 2 + x2
        local x3 = w3 / 2 + w2 / 2 + x2
        image1:SetPosition(x1, 0, 0)
        image2:SetPosition(x2, 0, 0)
        image3:SetPosition(x3, 0, 0)
        self.width = w1 + w2 + w3
        self.height = height
    elseif self.mode == "slice31" then
        local image1 = self.images[1]
        local image2 = self.images[2]
        local image3 = self.images[3]
        local texScale = math.min(self.texScale, math.min(height / (image1.originHeight + image3.originHeight), width / image1.originWidth))
        local h1 = math.floor(image1.originHeight * texScale)
        local h3 = math.floor(image3.originHeight * texScale)
        local h2 = math.max(0, height - h1 - h3)
        image1:SetSize(width, h1)
        image2:SetSize(width, h2)
        image3:SetSize(width, h3)
        local y2 = (h1 - h3) / 2
        local y1 = -h1 / 2 - h2 / 2 + y2
        local y3 = h3 / 2 + h2 / 2 + y2
        image1:SetPosition(0, y1, 0)
        image2:SetPosition(0, y2, 0)
        image3:SetPosition(0, y3, 0)
        self.height = h1 + h2 + h3
        self.width = width
    elseif self.mode == "slice33" then
        local images = self.images
        local texScale = math.min(self.texScale, math.min(width / (images[11].originWidth + images[13].originWidth), height / (images[11].originHeight + images[31].originHeight)))
        local ws, hs, xs, ys = {}, {}, {}, {}
        ws[1] = math.floor(images[11].originWidth * texScale)
        ws[3] = math.floor(images[13].originWidth * texScale)
        ws[2] = math.max(0, width - ws[1] - ws[3])
        hs[1] = math.floor(images[11].originHeight * texScale)
        hs[3] = math.floor(images[31].originHeight * texScale)
        hs[2] = math.max(0, height - hs[1] - hs[3])
        xs[2] = (ws[1] - ws[3]) / 2
        xs[1] = -ws[1] / 2 - ws[2] / 2 + xs[2]
        xs[3] = ws[3] / 2 + ws[2] / 2 + xs[2]
        ys[2] = (hs[1] - hs[3]) / 2
        ys[1] = -hs[1] / 2 - hs[2] / 2 + ys[2]
        ys[3] = hs[3] / 2 + hs[2] / 2 + ys[2]
        for i = 1, 3 do
            for j = 1, 3 do
                images[i * 10 + j]:SetSize(ws[j], hs[i])
                images[i * 10 + j]:SetPosition(xs[j], ys[i], 0)
            end
        end
        self.width = ws[1] + ws[2] + ws[3]
        self.height = hs[1] + hs[2] + hs[3]
    end
    return self
end

function SomniumSlicedImage:GetSize() return self.width, self.height end

function SomniumSlicedImage:SetTint(r, g, b, a) for _, image in pairs(self.images) do image:SetTint(r, g, b, a) end end

function SomniumSlicedImage:SetClickable(clickable) for _, image in pairs(self.images) do image:SetClickable(clickable) end end

return SomniumSlicedImage

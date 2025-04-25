local function onSprintDirty(self, enabled) end
local onTailDirty = function(self, enabled) end

--- 该组件管理语音 台词等的东西以及一些行为相关的开关等，当然包括classified
-- 顺便统一管理一些rpc和本地设置的东西吧，原本的太傻x了
-- 变量同步在keqing_classified里面
local Keqing = Class(
	function(self, inst)
		self.inst = inst
		self.sprint = false
		self.isSoundEnabled = true
		-- 这个配置要提供个选项，在本地加载进入时读取本地设置给服务器发送rpc设置是否启用
		self.tail = false
	end,
	nil,
	{
		-- 这里原则上只用来向本地同步
		sprint = onSprintDirty,
		tail = onTailDirty,
	}
)
function Keqing:OnLoad(data)
	if data ~= nil then
		self.sprint = data.sprint or false
		self.isSoundEnabled = data.isSoundEnabled or true
		self.tail = data.tail or false
	end
	self:EnableTail(self.tail)
end
function Keqing:EnableSprint(enable) end

function Keqing:EnableTail(enabled)
	if enabled then
		local player = self.inst
		player.tail_task = player:DoTaskInTime(2, function() -- 拖尾
			player.kq_tailing = SpawnPrefab("kq_tailing_fx")
			if player.kq_tailing ~= nil then
				player.kq_tailing_offset = -105
				player.kq_tailing.entity:AddFollower()
				player.kq_tailing.entity:SetParent(player.entity)
				player.kq_tailing.Follower:FollowSymbol(player.GUID, "swap_body", 0, player.kq_tailing_offset or 0, 0)
			end
		end)
	else
		self.inst.tail_task = nil
	end
end

return Keqing

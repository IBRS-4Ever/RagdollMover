
include("shared.lua");
AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

local TYPE_ARROW = 1;
local TYPE_ARROWSIDE = 2;
local TYPE_DISC = 3;

local RED = Color(255, 0, 0, 255);
local GREEN = Color(0, 255, 0, 255);
local BLUE = Color(0, 0, 255, 255);
local GREY = Color(175,175,175,255);

function ENT:MakeGizmo(name)
	
	local gizmo = ents.Create(name);
	gizmo:SetParent(self);
	gizmo:Spawn();
	gizmo:SetLocalPos(Vector(0, 0, 0));
	gizmo:SetLocalAngles(Angle(0, 0, 0));
	
end

function ENT:Initialize()

	self:InitializeShared();
	
	self.m_MoveGizmo = self:MakeGizmo("rgm_gizmo_move");
	self.m_RotateGizmo = self:MakeGizmo("rgm_gizmo_rotate");
	self.m_ScaleGizmo = self:MakeGizmo("rgm_gizmo_scale");
	
	self.m_Gizmos = 
	{
		self.m_MoveGizmo,
		self.m_RotateGizmo,
		self.m_ScaleGizmo,
	};
	
	self:SendMessage("SetupGizmos", self.MoveGizmo, self.RotateGizmo, self.ScaleGizmo);
	
end

---
-- Enable the manipulator. (See IsEnabled)
---
function ENT:Enable()
	self:SetNWBool("Enabled", true);
end

---
-- Disable the manipulator. (See IsEnabled)
---
function ENT:Disable()
	self:SetNWBool("Enabled", false);
end

function ENT:SetPlayer(player)
	self:SetNWEntity("Player", player);
end

---
-- Set the target skeleton node of the manipulator
---
function ENT:SetTarget(target)

	if target:GetClassName() ~= "rgm_skeleton_node" then
		error("rgm_manipulator SetTarget - target not node type");
	end

	self:SetNWEntity("Target", target);
	return true;

end

function ENT:SetMode(mode)
	self:SetNWInt("Mode", mode);
end

---
-- Attempt to grab an axis from the player's eye trace.
-- If no axis is traced, returns false,
-- If an axis is traced, creates grab data for this axis and returns true.
---
function ENT:Grab()
	
	if not self:IsEnabled() then return false; end

	local trace = self:GetTrace();
	if not trace.success then return false; end
	
	local gdata = rgm.GrabData(trace.axis, trace.axisOffset);

	self:SetNWEntity("GrabData_Axis", gdata.axis);
	self:SetNWVector("GrabData_AxisOffset", gdata.axisOffset);
	self:SetNWBool("Grabbed", true);

	-- Call callbacks
	self:GetTarget():GetSkeleton():OnGrab();
	self:GetTarget():OnGrab();
	
	return true;
	
end

---
-- If an axis is grabbed, it is released. This removes rgm grab data.
---
function ENT:Release()

	if not self:IsEnabled() then return false; end

	self.m_GrabData = nil;

	-- Call callbacks
	self:GetTarget():GetSkeleton():OnRelease();
	self:GetTarget():OnRelease();

	return true;

end

---
-- If grabbed, updates the skeleton position.
-- If not grabbed, doesn't really do anything
---
function ENT:Update()

	if not self:IsEnabled() then return; end

	if not self:IsGrabbed() then return; end

	local gizmo = self:GetActiveGizmo();
	if not IsValid(gizmo) then return; end --Shouldn't happen

	gizmo:Update();

end

---
-- "Quiet" functionality to keep the manipulator on the target skeleton node.
---
function ENT:Think()

	-- TODO

end
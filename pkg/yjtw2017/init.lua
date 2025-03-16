local extension = Package("yjtw2017")
extension.extensionName = "yjtw"

Fk:loadTranslationTable{
  ["yjtw2017"] = "台湾一将2017",
}

local caohong = General(extension, "tw__caohong", "wei", 4)
local tw__huzhu = fk.CreateActiveSkill{
  name = "tw__huzhu",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#tw__huzhu",
  can_use = function(self, player)
    return #player:getCardIds("e") > 0 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCard(target, 1, 1, false, self.name, false, ".", "#tw__huzhu-give:"..player.id)
    room:obtainCard(player.id, card[1], false, fk.ReasonGive)
    if not player.dead and not target.dead and #player:getCardIds("e") > 0 then
      local id = room:askForCardChosen(target, player, "e", self.name)
      room:obtainCard(target.id, id, true, fk.ReasonPrey)
    end
    if not player.dead and not target.dead and target:isWounded() and player.hp >= target.hp and
      room:askForSkillInvoke(player, self.name, nil, "#tw__huzhu-invoke::"..target.id) then
        room:recover{
          who = target,
          num = 1,
          recoverBy = player,
          skillName = self.name,
        }
    end
  end,
}
local tw__liancai = fk.CreateTriggerSkill{
  name = "tw__liancai",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart, fk.TurnedOver},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return player.phase == Player.Finish and table.find(player.room.alive_players, function(p) return #p:getCardIds("e") > 0 end)
      else
        return player:getHandcardNum() < player.hp
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local targets = table.map(table.filter(room.alive_players, function(p)
        return #p:getCardIds("e") > 0 end), function (p) return p.id end)
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#tw__liancai-choose", self.name, true)
      if #to > 0 then
        self.cost_data = to[1]
        return true
      end
    else
      return room:askForSkillInvoke(player, self.name, nil, "#tw__liancai-invoke")
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.EventPhaseStart then
      local room = player.room
      player:turnOver()
      local to = room:getPlayerById(self.cost_data)
      if not player.dead and not to.dead and #to:getCardIds("e") > 0 then
        local id = room:askForCardChosen(player, to, "e", self.name)
        room:obtainCard(player.id, id, true, fk.ReasonPrey)
      end
    else
      player:drawCards(player.hp - player:getHandcardNum(), self.name)
    end
  end,
}
caohong:addSkill(tw__huzhu)
caohong:addSkill(tw__liancai)
Fk:loadTranslationTable{
  ["tw__caohong"] = "曹洪",
  ["tw__huzhu"] = "护主",
  [":tw__huzhu"] = "出牌階段限一次，若你的裝備區有牌，你可以令一名其他角色交給你一張手牌，然後其獲得你裝備區的一張牌。若其體力值不大於你，"..
  "你可以令其回復1點體力。",
  ["tw__liancai"] = "敛财",
  [":tw__liancai"] = "結束階段開始時，你可以翻面並獲得一名角色裝備區內的一張牌。每當你翻面後，你可以將手牌摸至體力值。",
  ["#tw__huzhu"] = "护主：令一名其他角色交给你一张手牌，然后其获得你装备区一张牌",
  ["#tw__huzhu-give"] = "护主：交给 %src 一张手牌，然后你获得其装备区的一张牌",
  ["#tw__huzhu-invoke"] = "护主：你可以令 %dest 回复1点体力",
  ["#tw__liancai-choose"] = "敛财：你可以翻面并获得一名角色装备区内一张牌",
  ["#tw__liancai-invoke"] = "敛财：你可以摸牌至体力值",
}

local maliang = General(extension, "tw__maliang", "shu", 3)
local tw__rangyi = fk.CreateActiveSkill{
  name = "tw__rangyi",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#tw__rangyi",
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = table.simpleClone(player:getCardIds("h"))
    local dummy1 = Fk:cloneCard("dilu")
    dummy1:addSubcards(cards)
    room:obtainCard(target.id, dummy1, false, fk.ReasonGive)
    if target.dead then return end
    local pattern = "^(jink,nullification)|.|.|.|.|.|"
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id)
      if not target:prohibitUse(card) and target:canUse(card) then
        pattern = pattern..id..","
      end
    end
    pattern = string.sub(pattern, 1, #pattern - 1)
    local use = room:askForUseCard(target, "", pattern, "#tw__rangyi-use:"..player.id, true)
    if use then
      if not player.dead then
        table.removeOne(cards, use.card:getEffectiveId())
        local dummy2 = Fk:cloneCard("dilu")
        dummy2:addSubcards(cards)
        room:obtainCard(player.id, dummy2, false, fk.ReasonGive)
      end
      room:useCard(use)
    else
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
local tw__baimei = fk.CreateTriggerSkill{
  name = "tw__baimei",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:isKongcheng() and
      ((data.card and data.card.type == Card.TypeTrick) or data.damageType ~= fk.NormalDamage)
  end,
  on_use = Util.TrueFunc,
}
maliang:addSkill(tw__rangyi)
maliang:addSkill(tw__baimei)
Fk:loadTranslationTable{
  ["tw__maliang"] = "马良",
  ["tw__rangyi"] = "攘夷",
  [":tw__rangyi"] = "出牌階段限一次，你可以將所有手牌交給一名其他角色，其選擇一項：1.使用其中一張牌，结算前交還給你其餘的牌；2.你對其造成1點傷害。",
  ["tw__baimei"] = "白眉",
  [":tw__baimei"] = "鎖定技，若你沒有手牌，防止你受到的錦囊牌傷害和屬性傷害。",
  ["#tw__rangyi"] = "攘夷：将所有手牌交给一名角色，其使用其中一张牌或你对其造成1点伤害",
  ["#tw__rangyi-use"] = "攘夷：你需使用其中一张牌并交还给 %src 其余的牌，否则其对你造成1点伤害",
}

local dingfeng = General(extension, "tw__dingfeng", "wu", 4)
local tw__qijia = fk.CreateActiveSkill{
  name = "tw__qijia",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#tw__qijia",
  can_use = function(self, player)
    return #player:getCardIds("e") > 0
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and Fk:currentRoom():getCardArea(to_select) == Player.Equip then
      return Self:getMark("tw__qijia_"..Fk:getCardById(to_select):getSubtypeString().."-phase") == 0
    end
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and Self:inMyAttackRange(target) and not Self:isProhibited(target, Fk:cloneCard("slash"))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:setPlayerMark(player, "tw__qijia_"..Fk:getCardById(effect.cards[1]):getSubtypeString().."-phase", 1)
    room:throwCard(effect.cards, self.name, player, player)
    room:useVirtualCard("slash", nil, player, target, self.name, true)
  end,
}
local tw__zhuchen = fk.CreateActiveSkill{
  name = "tw__zhuchen",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  prompt = "#tw__zhuchen",
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, targets)
    return #selected == 0 and table.contains({"peach", "analeptic"}, Fk:getCardById(to_select).trueName)
  end,
  target_filter = function(self, to_select, selected, cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:setPlayerMark(room:getPlayerById(effect.tos[1]), "tw__zhuchen-turn", player.id)
  end,
}
local tw__zhuchen_distance = fk.CreateDistanceSkill{
  name = "#tw__zhuchen_distance",
  fixed_func = function(self, from, to)
    if to:getMark("tw__zhuchen-turn") == from.id then
      return 1
    end
  end,
}
tw__zhuchen:addRelatedSkill(tw__zhuchen_distance)
dingfeng:addSkill(tw__qijia)
dingfeng:addSkill(tw__zhuchen)
Fk:loadTranslationTable{
  ["tw__dingfeng"] = "丁奉",
  ["tw__qijia"] = "弃甲",
  [":tw__qijia"] = "出牌階段，你可以棄置裝備區內一張牌（每種副類別每階段限一次），視為對攻擊範圍內一名角色使用一張不計次數的【殺】。",
  ["tw__zhuchen"] = "诛綝",
  [":tw__zhuchen"] = "出牌階段，你可以棄置一張【桃】或【酒】並指定一名其他角色，此階段你至其距離視為1。",
  ["#tw__qijia"] = "弃甲：弃置一张本阶段未弃置过副类别的装备，视为使用不计次数的【杀】",
  ["#tw__zhuchen"] = "诛綝：弃置一张【桃】或【酒】，本阶段至一名角色距离视为1",
}

return extension

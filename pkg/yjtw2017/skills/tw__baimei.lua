local tw__baimei = fk.CreateSkill {
  name = "tw__baimei"
}

Fk:loadTranslationTable{
  ['tw__baimei'] = '白眉',
  [':tw__baimei'] = '鎖定技，若你沒有手牌，防止你受到的錦囊牌傷害和屬性傷害。',
}

tw__baimei:addEffect(fk.DamageInflicted, {
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tw__baimei.name) and player:isKongcheng() and
    ((data.card and data.card.type == Card.TypeTrick) or data.damageType ~= fk.NormalDamage)
  end,
  on_use = Util.TrueFunc,
})

return tw__baimei

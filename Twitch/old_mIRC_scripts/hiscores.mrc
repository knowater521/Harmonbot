on *:text:!hiscore*:#:{
  $hiscores($1, $2, $3, $4, $5)
  set %channel #
  timer 1 2 hiscores_print
}
on *:text:!highscore*:#:{
  $hiscores($1, $2, $3, $4, $5)
  set %channel #
  timer 1 2 hiscores_print
}

alias hiscores_print { msg %channel %hiscores_return }

alias hiscores {
  if ($sock(hiscores)) { sockclose hiscores }
  set %hiscores_username $2
  if ($3 == total) { set %hiscores_skill_number 11 }
  else if ($3 == attack || $3 == att || $3 == atk) {
    set %hiscores_skill_number 12
    set %hiscores_skill Attack
  }
  else if ($3 == defence || $3 == def) {
    set %hiscores_skill_number 13
    set %hiscores_skill Defence
  }
  else if ($3 == strength || $3 == str) {
    set %hiscores_skill_number 14
    set %hiscores_skill Strength
  }
  else if ($3 == constitution || $3 == hp) {
    set %hiscores_skill_number 15
    set %hiscores_skill Constitution
  }
  else if ($3 == ranged || $3 == range) {
    set %hiscores_skill_number 16
    set %hiscores_skill Ranged
  }
  else if ($3 == prayer || $3 == pray) {
    set %hiscores_skill_number 17
    set %hiscores_skill Prayer
  }
  else if ($3 == magic || $3 == mage) {
    set %hiscores_skill_number 18
    set %hiscores_skill Magic
  }
  else if ($3 == cooking || $3 == cook) {
    set %hiscores_skill_number 19
    set %hiscores_skill Cooking
  }
  else if ($3 == woodcutting || $3 == wc) {
    set %hiscores_skill_number 20
    set %hiscores_skill Woodcutting
  }
  else if ($3 == fletching || $3 == fletch) {
    set %hiscores_skill_number 21
    set %hiscores_skill Fletching
  }
  else if ($3 == fishing || $3 == fish) {
    set %hiscores_skill_number 22
    set %hiscores_skill Fishing
  }
  else if ($3 == firemaking || $3 == fm) {
    set %hiscores_skill_number 23
    set %hiscores_skill Firemaking
  }
  else if ($3 == crafting || $3 == craft) {
    set %hiscores_skill_number 24
    set %hiscores_skill Crafting
  }
  else if ($3 == smithing || $3 == smith) {
    set %hiscores_skill_number 25
    set %hiscores_skill Smithing
  }
  else if ($3 == mining || $3 == mine) {
    set %hiscores_skill_number 26
    set %hiscores_skill Mining
  }
  else if ($3 == herblore || $3 == herb) {
    set %hiscores_skill_number 27
    set %hiscores_skill Herblore
  }
  else if ($3 == agility) {
    set %hiscores_skill_number 28
    set %hiscores_skill Agility
  }
  else if ($3 == thieving || $3 == thief) {
    set %hiscores_skill_number 29
    set %hiscores_skill Thieving
  }
  else if ($3 == slayer || $3 == slay) {
    set %hiscores_skill_number 30
    set %hiscores_skill Slayer
  }
  else if ($3 == farming || $3 == farm) {
    set %hiscores_skill_number 31
    set %hiscores_skill Farming
  }
  else if ($3 == runecrafting || $3 == rc) {
    set %hiscores_skill_number 32
    set %hiscores_skill Runecrafting
  }
  else if ($3 == hunter || $3 == hunt) {
    set %hiscores_skill_number 33
    set %hiscores_skill Hunter
  }
  else if ($3 == construction || $3 == con) {
    set %hiscores_skill_number 34
    set %hiscores_skill Construction
  }
  else if ($3 == summoning) {
    set %hiscores_skill_number 35
    set %hiscores_skill Summoning
  }
  else if (($3 == dungeoneering || $3 == dung || $3 == dg) && (!$4 || $4 == rs3 || $4 == rs3ironman || $4 == rs3hcironman)) {
    set %hiscores_skill_number 36
    set %hiscores_skill Dungeoneering
  }
  else if (($3 == divination || $3 == div) && (!$4 || $4 == rs3 || $4 == rs3ironman || $4 == rs3hcironman)) {
    set %hiscores_skill_number 37
    set %hiscores_skill Divination
  }
  else if (($3 == invention || $3 == inventor) && (!$4 || $4 == rs3 || $4 == rs3ironman || $4 == rs3hcironman)) {
    set %hiscores_skill_number 38
    set %hiscores_skill Invention
  }
  else {
    set %hiscores_return That is not a valid username/skill. Use _'s for spaces in usernames. Format: !hiscores <username> <skill / total> <rs3 / 07 / rs3ironman / rs3hcironman / 07ironman / 07hcironman / 07deadman> <level / rank / xp> 
    return
  }
  if ($4 == rs3) {
    set %hiscores_host hiscore.runescape.com 
    set %hiscores_url /index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which RS3
  }
  else if ($4 == rs3ironman) {
    set %hiscores_host services.runescape.com
    set %hiscores_url /m=hiscore_ironman/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which RS3 (Ironman)
  }
  else if ($4 == rs3hcironman) {
    set %hiscores_host services.runescape.com
    set %hiscores_url /m=hiscore_hardcore_ironman/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which RS3 (Hardcore Ironman)
  }
  else if ($4 == 07 || $4 == osrs) {
    set %hiscores_host services.runescape.com 
    set %hiscores_url /m=hiscore_oldschool/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which OSRS
  }
  else if ($4 == 07ironman || $4 == osrsironman ) {
    set %hiscores_host services.runescape.com
    set %hiscores_url /m=hiscore_oldschool_ironman/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which OSRS (Ironman)
  }
  else if ($4 == 07hcironman || $4 == osrshcironman || $4 == 07ultimateironman || $4 == osrsultimateironman ) {
    set %hiscores_host services.runescape.com
    set %hiscores_url /m=hiscore_oldschool_ultimate/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which OSRS (Ultimate Ironman)
  }
  else if ($4 == 07deadman || $4 == osrsdeadman) {
    set %hiscores_host services.runescape.com
    set %hiscores_url /m=hiscore_oldschool_deadman/index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which OSRS (Deadman)
  }
  else {
    set %hiscores_host hiscore.runescape.com 
    set %hiscores_url /index_lite.ws?player= $+ %hiscores_username
    set %hiscores_which RS3
  }
  if ($5 == rank) { set %hiscores_option 1 }
  else if ($5 == xp || $5 == exp) { set %hiscores_option 3 }
  else { set %hiscores_option 2 }
  sockopen hiscores %hiscores_host 80
}

on *:SOCKOPEN:hiscores: {
  sockwrite -nt $sockname GET %hiscores_url HTTP/1.1
  sockwrite -nt $sockname Host: %hiscores_host
  sockwrite $sockname $crlf
  set %hiscores_counter 0
}

on *:SOCKREAD:hiscores: {
  if (!$sockerr) {
    var %sockreader
    sockread %sockreader
    inc %hiscores_counter
    if ($gettok(%sockreader, 2, 32) == 404) {
      set %hiscores_return Username not found.
      sockclose hiscores
    }
    if (%hiscores_counter == %hiscores_skill_number) {
      set %hiscores_display $bytes($gettok(%sockreader, %hiscores_option, 44),bd)
      if (%hiscores_skill_number == 11) {
        if (%hiscores_option == 2) { set %hiscores_return $capital(%hiscores_username) $+ 's total level is %hiscores_display on %hiscores_which $+ . }
        else if (%hiscores_option == 1) { set %hiscores_return  $capital(%hiscores_username) is rank %hiscores_display overall on %hiscores_which $+ . }
        else if (%hiscores_option == 3) { set %hiscores_return  $capital(%hiscores_username) has %hiscores_display total xp on %hiscores_which $+ . }
      }
      else if (%hiscores_option == 2) { set %hiscores_return  $capital(%hiscores_username) $+ 's %hiscores_skill level is %hiscores_display on %hiscores_which $+ . }
      else if (%hiscores_option == 1) { set %hiscores_return  $capital(%hiscores_username) is rank %hiscores_display in %hiscores_skill on %hiscores_which $+ . }
      else if (%hiscores_option == 3) { set %hiscores_return  $capital(%hiscores_username) has %hiscores_display XP in %hiscores_skill on %hiscores_which $+ . }
      sockclose hiscores
    }
  }
}

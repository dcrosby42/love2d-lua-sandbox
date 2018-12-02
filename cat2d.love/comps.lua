local Comp = require 'ecs/component'

Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
Comp.define("pos", {'x',0,'y',0})
Comp.define("vel", {'dx',0,'dy',0})

Comp.define("tag", {})

Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false, 'alarm',false})

Comp.define("controller", {'id','','leftx',0,'lefty',0,})

Comp.define("img", {'imgId','','centerx','','centery','','offx',0,'offy',0,'sx',1,'sy',1,'r',0,'color',{255,255,255},'drawBounds',false})

Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nilj, 'height',nil,'valign',nil})

Comp.define("iconAdder", {'imgId', '', 'tagName', ''})

Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'color',{0,0,0}})
Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill'})

Comp.define("event", {'data',''})

Comp.define("output", {'kind',''})

Comp.define("debug", {'value',''})

Comp.define("manipulator", {'id','','mode',''})

Comp.define("sound", {'sound','','loop',false,'state','stopped','volume',1,'pitch',1,'playtime',0,'duration',''})

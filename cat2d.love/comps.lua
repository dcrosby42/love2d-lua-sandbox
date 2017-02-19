local Comp = require 'ecs/component'
-- N.B. -- 'parent' and 'filter' components are BOTH DEFINED AND UTILIZED INTERNALLY BY ESTORE. (don't mess with them)

Comp.define("bounds", {'offx',0,'offy',0,'w',0,'h',0})
Comp.define("pos", {'x',0,'y',0})
Comp.define("vel", {'dx',0,'dy',0})

Comp.define("tag", {})

Comp.define("timer", {'t',0, 'reset',0, 'countDown',true, 'loop',false})

Comp.define("controller", {'id','','leftx',0,'lefty',0,})

Comp.define("img", {'imgId','','offx',0,'offy',0,'sx',1,'sy',1,'r',0})

Comp.define("label", {'text','Label', 'color', {0,0,0},'font',nil, 'width', nil, 'align',nilj, 'height',nil,'valign',nil})

Comp.define("iconAdder", {'imgId', '', 'tagName', ''})

Comp.define("circle", {'offx',0,'offy',0,'radius',0, 'color',{0,0,0}})
Comp.define("rect", {'offx',0,'offy',0,'w',0, 'h',0, 'color',{0,0,0}, 'style','fill'})

Comp.define("event", {'data',nil})

Comp.define("output", {'kind',nil})

local Comp = require 'ecs/component'

Comp.define("controller", {'id','','leftx',0,'lefty',0,})

Comp.define("pos", {'x',0,'y',0})

Comp.define("bounds", {'x',0,'y',0,'w',0,'h',0})

Comp.define("img", {'imgId','','offx',0,'offy',0,'sx',1,'sy',1,'r',0})
Comp.define("label", {'text','Label', 'r',0, 'g',0, 'b',0})

Comp.define("tag", {})

Comp.define("iconAdder", {'imgId', '', 'tagName', ''})

Comp.define("parent", {'parentEid', ''})
Comp.define("filter", {'bits', 0})

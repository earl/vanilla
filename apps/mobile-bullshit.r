; 2000-05-06 should be sleeping (rather)

doc: func [] [
	"nobody should have to travel great lengths w/o access to web economy bullshit"
	]

handle: func [/local verbs adverbs nouns] [
	verbs: ["implement" "utilize" "integrate" "streamline" "optimize" "evolve" "transform" "embrace" "enable" "orchestrate" "leverage" "reinvent" "aggregate" "architect" "enhance" "incentivize" "morph" "empower" "envisioneer" "monetize" "harness" "facilitate" "seize" "disintermediate" "synergize" "strategize" "deploy" "brand" "grow" "target" "syndicate" "synthesize" "deliver" "mesh" "incubate" "engage" "maximize" "benchmark" "expedite" "reintermediate"]

	adverbs: ["clicks-and-mortar" "value-added" "vertical" "proactive" "robust" "revolutionary" "scalable" "leading-edge" "innovative" "intuitive" "strategic" "e-business" "mission-critical" "sticky" "one-to-one" "24/7" "end-to-end" "global" "B2B" "B2C" "granular" "frictionless" "virtual" "viral" "dynamic" "24/365" "best-of-breed" "killer" "magnetic" "bleeding-edge" "web-enabled" "interactive" "dot-com" "sexy" "back-end" "real-time" "efficient" "front-end" "distributed" "seamless" "extensible" "turnkey" "world-class" "open-source" "cross-platform" "B2B2C" "cross-media" "synergistic" "bricks-and-clicks" "out-of-the-box" "enterprise"]

	nouns: ["synergies" "web-readiness" "paradigms" "markets" "partnerships" "infrastructures" "platforms" "initiatives" "channels" "eyeballs" "communities" "ROI" "earballs" "solutions" "e-tailers" "e-services" "action-items" "portals" "niches" "technologies" "content" "vortals" "supply-chains" "convergence" "relationships" "architectures" "interfaces" "e-markets" "e-commerce" "systems" "bandwidth" "infomediaries" "models" "mindshare" "deliverables" "users" "schemas" "networks"]

	random/seed now
	
	return rejoin [pick verbs random length? verbs " " pick adverbs random length? adverbs " " pick nouns random length? nouns]
	]
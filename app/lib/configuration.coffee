# Which survey are we providing a tutorial on? We'll need to
# specify the images to use, and the text to display, at each step.
CFHTLSStage1TutorialSteps = require 'lib/tutorial/tutorial_stepsCFHTLSstage1'
CFHTLSStage2TutorialSteps = require 'lib/tutorial/tutorial_stepsCFHTLSstage2'
VICS82TutorialSteps = require 'lib/tutorial/tutorial_stepsVICS82'
CFHTLSRebootTutorialSteps = require 'lib/tutorial/tutorial_stepsCFHTLSreboot'

CFHTLSTutorialSubject = require 'lib/tutorial/tutorial_subjectCFHTLS'
VICS82TutorialSubject = require 'lib/tutorial/tutorial_subjectVICS82'

# Instant feedback is survey and stage dependent
CFHTLSStage1CreateFeedback = require 'lib/feedback/create_feedbackCFHTLSstage1'
CFHTLSStage2CreateFeedback = require 'lib/feedback/create_feedbackCFHTLSstage2'
VICS82CreateFeedback = require 'lib/feedback/create_feedbackVICS82'

# Which survey are we supporting with this Spotter's Guide?
CFHTLSStage2GuideTemplate = require 'views/guide/guideCFHTLSstage2'
VICS82GuideTemplate = require 'views/guide/guideVICS82'

# Which survey are we introducing?
CFHTLSStage1AboutTemplate = require 'views/about/aboutCFHTLSstage1'
CFHTLSStage2AboutTemplate = require 'views/about/aboutCFHTLSstage2'
VICS82AboutTemplate = require 'views/about/aboutVICS82'
CFHTLSRebootAboutTemplate = require 'views/about/aboutCFHTLSreboot'

# Which survey are we supporting with this Quick Spotter's Guide?
# Note that the images to use (and the title text to pop up) are
# specified in translations/en_US.coffee!
CFHTLSStage2QuickGuideTemplate = require 'views/quick_guide/quick_guideCFHTLSstage2' # This was unchanged from CFHTLS Stage 1.
VICS82QuickGuideTemplate = require 'views/quick_guide/quick_guideVICS82'

# Which survey are we currently hosting? Or are we re-directing people?
CFHTLSStage1HomeTemplate = require 'views/home/landingCFHTLSstage1'
CFHTLSStage2HomeTemplate = require 'views/home/landingCFHTLSstage2'
VICS82HomeTemplate = require 'views/home/landingVICS82'
VICS82DivertHomeTemplate = require 'views/home/celebrate-VICS82-then-divert'
CFHTLSRebootHomeTemplate =require 'views/home/landingCFHTLSreboot'

module.exports =
  TutorialSteps: CFHTLSRebootTutorialSteps
  TutorialSubject: CFHTLSTutorialSubject
  CreateFeedback: CFHTLSStage2CreateFeedback
  GuideTemplate: CFHTLSStage2GuideTemplate
  AboutTemplate: CFHTLSRebootAboutTemplate
  QuickGuideTemplate: CFHTLSStage2QuickGuideTemplate
  HomeTemplate: CFHTLSRebootHomeTemplate

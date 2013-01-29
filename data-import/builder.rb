
# Set up SpaceWarps project and workflow

ProjectName = 'spacewarps'
SubjectRoot = '/subjects/standard'

ProjectId         = BSON::ObjectId('5101a1341a320ea77f000001')
WorkflowId        = BSON::ObjectId('5101a1361a320ea77f000002')
TutorialSubjectId = BSON::ObjectId('5101a1931a320ea77f000003')

ProjectSubject = SpacewarpSubject

@project = Project.where(name: ProjectName).first || Project.create({
  _id: ProjectId,
  name: ProjectName
})

@workflow = @project.workflows.first || Workflow.create({
  _id: WorkflowId,
  project_id: @project.id,
  primary: true,
  name: ProjectName,
  description: ProjectName,
  entities: []
})

# Clean database before creating subjects
Classification.where(project_id: @project.id).destroy_all
Recent.where(project_id: @project.id).destroy_all
Favorite.where(project_id: @project.id).destroy_all
ProjectSubject.destroy_all


# Create a tutorial subject

unless SpacewarpSubject.find(TutorialSubjectId)
  ProjectSubject.create({
    _id: TutorialSubjectId,
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    tutorial: 'true',
    location: {},
    coords: [],
    metadata: {}
  })
end

# Create subjects
(1..30).each do |index|
  
  # TODO: Use S3 location
  standard = "http://0.0.0.0:9294/subjects/standard/CFHTLS_%02d.png" % index
  thumbnail = "http://0.0.0.0:9294/subjects/thumbnail/CFHTLS_%02d.png" % index
  ProjectSubject.create({
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    location: {standard: standard, thumbnail: thumbnail},
    coords: [],
    metadata: {}
  })
end


ProjectSubject.activate_randomly if Rails.env == "development"
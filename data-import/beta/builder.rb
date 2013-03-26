# Set up SpaceWarps project and workflow

ProjectName = 'spacewarp'
SubjectRoot = '/subjects/standard'

ProjectId           = BSON::ObjectId('5101a1341a320ea77f000001')
WorkflowId          = BSON::ObjectId('5101a1361a320ea77f000002')

TutorialSubjectId1  = BSON::ObjectId('5101a1931a320ea77f000003')
TutorialSubjectId2  = BSON::ObjectId('5101a1931a320ea77f000004')
TutorialSubjectId3  = BSON::ObjectId('5101a1931a320ea77f000005')

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
SpacewarpClassification.destroy_all
Favorite.where(project_id: @project.id).destroy_all
ProjectSubject.destroy_all

# Create a tutorial subjects

unless SpacewarpSubject.find(TutorialSubjectId1)
  ProjectSubject.create({
    _id: TutorialSubjectId1,
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    tutorial: 'true',
    location: {},
    metadata: {}
  })
end

unless SpacewarpSubject.find(TutorialSubjectId2)
  ProjectSubject.create({
    _id: TutorialSubjectId2,
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    tutorial: 'true',
    location: {},
    metadata: {}
  })
end

unless SpacewarpSubject.find(TutorialSubjectId3)
  ProjectSubject.create({
    _id: TutorialSubjectId3,
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    tutorial: 'true',
    location: {},
    metadata: {}
  })
end

# Get metadata from file(s)
all_metadata = {}
File.open(File.join(File.dirname(__FILE__), 'lens_info'), 'r') do |f1|
  while line = f1.gets
    data = line.split(' ')
    id = data[0]
    x = data[1]
    y = data[2]
    type = "#{data[3]} #{data[4]}"
    all_metadata[id] = {
      "x" => x,
      "y" => y,
      "type" => type
    }
  end
end


# Create subjects
dirname = File.dirname(__FILE__)
standard_dir = File.join(File.dirname(__FILE__), 'subjects', 'standard')

Dir.entries(standard_dir).each do |file|
  next if file == '.'
  next if file == '..'
  
  prefix = file.split('_gri.png')[0]
  sim_data = all_metadata[prefix]
  
  standard  = "http://www.spacewarps.org.s3.amazonaws.com/beta/subjects/standard/#{prefix}_gri.png"
  thumbnail = "http://www.spacewarps.org.s3.amazonaws.com/beta/subjects/thumbnail/#{prefix}_gri.png"
  
  metadata = {
    id: prefix
  }
  
  # Add simulation metadata if exist
  if sim_data
    metadata['training'] = {
      type: sim_data['type'],
      x: sim_data['x'],
      y: sim_data['y']
    }
  end
  
  ProjectSubject.create({
    project_id: @project.id,
    workflow_ids: [@workflow.id],
    location: {standard: standard, thumbnail: thumbnail},
    metadata: {id: prefix},
  })
end

ProjectSubject.activate_randomly if Rails.env == 'development'

Subject = require 'zooniverse/models/subject'

module.exports =
  main:
    new Subject
      id: '5101a1931a320ea77f000003'
      location:
        standard: 'images/tutorial/tutorial-1.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'lensed galaxy'
        id: 'CFHTLS_078_1721'
      tutorial: true
      zooniverse_id: 'ASW0000001'
  simulated:
    new Subject
      id: '5101a1931a320ea77f000004'
      location:
        standard: 'images/tutorial/tutorial-2.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'lensed galaxy'
          x: 61.010010
          y: 319.750000
        id: 'CFHTLS_079_2328'
      tutorial: true
      zooniverse_id: 'ASW0000002'
  empty:
    new Subject
      id: '5101a1931a320ea77f000005'
      location:
        standard: 'images/tutorial/tutorial-3.png'
      project_id: '5101a1341a320ea77f000001'
      workflow_ids: ['5101a1361a320ea77f000002']
      metadata:
        training:
          type: 'empty'
        id: 'CFHTLS_082_0054'
      tutorial: true
      zooniverse_id: 'ASW0000003'
    
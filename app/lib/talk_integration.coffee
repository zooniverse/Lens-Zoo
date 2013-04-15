

module.exports =
  
  # Authentication appended to header
  setAuthentication: (user) ->
    auth = base64.encode("#{user.name}:#{user.api_key}")
    headers = {}
    headers['Authorization'] = "Basic #{auth}"
    
    return headers
  
  # List Talk collections owned by user
  getTalkCollections: (user) ->
    
    # Send the request
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/users/collection_list",
      dataType: 'json',
      success: (collections, status, response) =>
        @setTalkCollection(user, collections)
      headers: @setAuthentication(user)
    })
  
  # Set a Quick Dashboard collection unless it exists
  setTalkCollection: (user, collections) ->
    
    # Check users collections for Quick Dashboard
    for collection in collections
      if collection.title is @dashboardCollection
        @collectionId = collection.zooniverse_id
        return
    
    # Create collection for user
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/collections",
      type: 'POST',
      data: {subject_id: 'ASW0000001', title: @dashboardCollection, description: 'A collection of all Space Warp images examined in the Quick Dashboard.'},
      headers: @setAuthentication(user),
      success: (collection, status, response) =>
        @collectionId = collection.zooniverse_id
    })
  
  # Add subject to Talk collection
  addToTalkCollection: (user, zooniverseId) ->
    
    $.ajax({
      url: "#{@constructor.host}/projects/spacewarp/talk/collections/#{@collectionId}/add_subject",
      type: 'POST',
      data: {subject_id: zooniverseId},
      headers: @setAuthentication(user),
    })

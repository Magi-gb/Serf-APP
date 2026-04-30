test "should get index" do
  get plats_url
  assert_response :success
end

test "should get show" do
  get plat_url(plats(:paella))
  assert_response :success
end

test "should get new" do
  get new_plat_url
  assert_response :success
end

test "should get edit" do
  get edit_plat_url(plats(:paella))
  assert_response :success
end

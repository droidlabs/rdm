describe 'It works' do
  it "works" do
    File.open('fixture.txt', 'w') {|f| f.write('Repository spec working here!')}
  end
end

void loadConfig() {
  json = loadJSONObject("data/config.json");
  JSONArray PlottersData = json.getJSONArray("Plotters");
  JSONObject SelectedPlotter = PlottersData.getJSONObject(0);
  strwelcomeNote = SelectedPlotter.getString("welcomeNote");
  myPlotter.config(SelectedPlotter.getFloat("pulleyRadius"), SelectedPlotter.getInt("stepsPerRevolution"), SelectedPlotter.getFloat("DistBetweenPulleys"), SelectedPlotter.getFloat("HomeLocationX"), SelectedPlotter.getFloat("HomeLocationY"));
  println(strwelcomeNote);
  String[] paragraphs = loadStrings("config.json");
  configText = PApplet.join(paragraphs, '\n');
  if (txaconfig != null) txaconfig.setText(configText, 310);
}

void saveConfig() {
  // Save new data
  String[] configLines=split(txaconfig.getText(), '\n');
  saveStrings("data/config.json", configLines);
  println("Configuration saved");
  //saveJSONObject(json, "data/data.json");
}

void applyConfig() {
  saveConfig();
  loadConfig();
  //saveJSONObject(json, "data/data.json");
  loadConfig();
}


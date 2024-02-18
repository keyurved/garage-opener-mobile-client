enum GarageState { OPEN, CLOSED }

class Garage {
  int garageNum;
  GarageState state;

  Garage({required this.garageNum, this.state = GarageState.CLOSED});

  String getGarageStatus() {
    if (state == GarageState.OPEN) {
      return 'open';
    } else {
      return 'closed';
    }
  }

  updateFromJson(Map<String, dynamic> json) {
    garageNum = json['garageNum'];
    state = json['status'] == 'open' ? GarageState.OPEN : GarageState.CLOSED;
  }

  factory Garage.fromJson(Map<String, dynamic> json) {
    return Garage(
      garageNum: json['garageNum'],
      state: json['status'] == 'open' ? GarageState.OPEN : GarageState.CLOSED,
    );
  }
}
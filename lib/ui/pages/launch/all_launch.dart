import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spacexopedia/bloc/launches/bloc.dart';
import 'package:flutter_spacexopedia/helper/app_font.dart';
import 'package:flutter_spacexopedia/helper/utils.dart';
import 'package:flutter_spacexopedia/ui/pages/common/no_connection.dart';
import 'package:flutter_spacexopedia/ui/pages/common/no_content.dart';
import 'package:flutter_spacexopedia/ui/pages/launch/launch_detail.dart';
import 'package:flutter_spacexopedia/ui/widgets/list_card.dart';
import 'package:flutter_spacexopedia/ui/widgets/title_text.dart';
import 'package:flutter_spacexopedia/ui/widgets/title_value.dart';
import 'package:google_fonts/google_fonts.dart';

class AllLaunch extends StatefulWidget {
  AllLaunch({Key key}) : super(key: key);

  @override
  _AllLaunchState createState() => _AllLaunchState();
}

class _AllLaunchState extends State<AllLaunch>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Column(
        children: <Widget>[
          Card(
            elevation: 3,
            margin: EdgeInsets.all(0),
            child: TabBar(
              labelStyle: GoogleFonts.montserrat(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              controller: _tabController,
              tabs: <Widget>[
                Text("Upcomming"),
                Text("Past"),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<LaunchBloc, LaunchState>(
              builder: (context, state) {
                if (state is Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is LoadedState) {
                  if (state.allLaunch == null) return NoContent();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      LaunchList(
                        list: state.allLaunch
                            .where((element) => element.upcoming)
                            .toList(),
                      ),
                      LaunchList(
                        list: state.allLaunch
                            .where((element) => !element.upcoming)
                            .toList(),
                      )
                    ],
                  );
                } else if (state is NoConnectionDragonState) {
                  return NoInternetConnection(
                    message: state.errorMessage,
                    onReload: () {
                      BlocProvider.of<LaunchBloc>(context).add(LaunchInitial());
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LaunchList extends StatelessWidget {
  const LaunchList({Key key, this.list}) : super(key: key);
  final List<Launch> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => LaunchCard(
        model: list[index],
      ),
    );
  }
}

class LaunchCard extends StatelessWidget {
  final Launch model;

  const LaunchCard({Key key, this.model}) : super(key: key);
  Widget _row(IconData icon, String value, ThemeData theme) {
    if (value == null) {
      value = "N/A";
    }
    return Row(
      children: <Widget>[
        Icon(icon,
            size: 15, color: theme.colorScheme.onSurface.withOpacity(.8)),
        SizedBox(width: 10),
        
        Text(value, style: TextStyle(color: theme.colorScheme.onSurface))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListCard(
      imagePath: model.links?.missionPatchSmall,
      imagePadding: EdgeInsets.all(10),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LaunchDetail(
              model: model,
            ),
          ),
        );
      },
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TitleText(model.missionName, fontSize:14),
          TitleValue(title:"Flight no:", value:model.flightNumber.toString()),
          _row(Icons.calendar_today,"${Utils.toformattedDate(model.launchDateLocal)}", theme),
          _row(AppFont.rocket2,model.rocket.rocketName, theme),
          _row(Icons.location_on, model.launchSite.siteName, theme),
        ],
      ),
    );
  }
}

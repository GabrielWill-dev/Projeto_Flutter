import 'package:flutter/material.dart';

class Task {
  String title;
  String description;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });
}

class ProfilePage extends StatefulWidget {
  final String userName;

  ProfilePage({required this.userName});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DateTime _currentDate = DateTime.now();
  List<Task> _tasks = [];
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();

  // Função para adicionar nova tarefa
  void _addTask() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _startTimeController.text.isNotEmpty &&
        _endTimeController.text.isNotEmpty) {
      try {
        setState(() {
          _tasks.add(Task(
            title: _titleController.text,
            description: _descriptionController.text,
            startTime: _parseTime(_startTimeController.text),
            endTime: _parseTime(_endTimeController.text),
          ));
          _titleController.clear();
          _descriptionController.clear();
          _startTimeController.clear();
          _endTimeController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar tarefa: Formato de hora inválido!')),
        );
      }
    } else {
      // Exibir um alerta se algum campo estiver vazio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos!')),
      );
    }
  }

  // Função para remover tarefa
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  // Função para reordenar tarefas
  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  // Função para formatar a entrada de hora
  TimeOfDay _parseTime(String time) {
    try {
      final isAmPm = time.contains(RegExp(r'AM|PM', caseSensitive: false));
      if (isAmPm) {
        final format = time.split(" ");
        final parts = format[0].split(":");
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final isPm = format[1].toUpperCase() == "PM";
        return TimeOfDay(
          hour: (isPm && hour != 12) ? hour + 12 : (hour == 12 && !isPm ? 0 : hour),
          minute: minute,
        );
      } else {
        final parts = time.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    } catch (e) {
      throw FormatException("Formato de hora inválido: $time");
    }
  }

  // Função para exibir o seletor de hora
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      controller.text = selectedTime.hour.toString().padLeft(2, '0') +
          ':' +
          selectedTime.minute.toString().padLeft(2, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: const Color.fromARGB(255, 59, 65, 71),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addTask,
            tooltip: 'Adicionar Tarefa',
          ),],
      ),
      backgroundColor: const Color.fromARGB(255, 24, 23, 23),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${widget.userName}!',
              style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Data: ${_currentDate.day}/${_currentDate.month}/${_currentDate.year}',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              'Suas tarefas do dia:',
              style: TextStyle(color: Colors.green, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ReorderableListView(
                onReorder: _reorderTasks,
                padding: EdgeInsets.symmetric(vertical: 8.0),
                children: List.generate(_tasks.length, (index) {
                  return Dismissible(
                    key: Key('$index-${_tasks[index].title}'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeTask(index);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      key: ValueKey('$index-${_tasks[index].title}'),
                      leading: IconButton(
                        icon: _tasks[index].isCompleted
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.check_circle_outline, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _tasks[index].isCompleted = !_tasks[index].isCompleted;
                          });
                        },
                      ),
                      title: Text(
                        _tasks[index].title,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descrição: ${_tasks[index].description}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            'Início: ${_tasks[index].startTime.format(context)}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            'Conclusão: ${_tasks[index].endTime.format(context)}',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.drag_handle, color: Colors.green),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título da tarefa',
                hintStyle: TextStyle(color: Colors.green),
                filled: true,
                fillColor: Colors.white12,
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Descrição da tarefa',
                hintStyle: TextStyle(color: Colors.green),
                filled: true,
                fillColor: Colors.white12,
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _startTimeController,
              decoration: InputDecoration(
                hintText: 'Hora de Início (HH:mm)',
                hintStyle: TextStyle(color: Colors.green),
                filled: true,
                fillColor: Colors.white12,
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time, color: Colors.green),
                  onPressed: () => _selectTime(context, _startTimeController),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _endTimeController,
              decoration: InputDecoration(
                hintText: 'Hora de Conclusão (HH:mm)',
                hintStyle: TextStyle(color: Colors.green),
                filled: true,
                fillColor: Colors.white12,
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time, color: Colors.green),
                  onPressed: () => _selectTime(context, _endTimeController),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

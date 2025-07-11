import 'package:flutter/material.dart';
import 'package:fyp/Apis/apisintegration.dart';
import 'package:fyp/Models/competitionattemptedquestions.dart';
import 'package:fyp/Models/questionmodel.dart';
import 'package:intl/intl.dart';

class Roundsummary extends StatefulWidget {
  final int roundid;
  final int teamid;

  const Roundsummary({super.key, required this.roundid, required this.teamid});

  @override
  State<Roundsummary> createState() => _RoundsummaryState();
}

class _RoundsummaryState extends State<Roundsummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: const Text(
          'Round Summary',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: FutureBuilder<List<CompetitionAttemptedQuestionModel>>(
            future: Api().getCompetitionSubmittedQuestions(
                widget.roundid, widget.teamid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                        strokeWidth: 5,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Loading your results...',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[400],
                        size: 70,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Failed to load data",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          "${snapshot.error}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => setState(() {}),
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.quiz_outlined,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "No questions attempted",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "You didn't attempt any questions in this round",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              final attempts = snapshot.data!;

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: attempts.length,
                itemBuilder: (context, index) {
                  final attempt = attempts[index];
                  final question = attempt.question;
                  final isType1 = question?.type == 1;
                  final isType3 = question?.type == 3;
                  print('Question Out Put${question?.output?.output}');

                  // For type 1 questions, use the direct answer
                  // For other types, find the selected option
                  final selectedOption = isType1 || isType3
                      ? null
                      : question?.options?.firstWhere(
                          (option) => option.id.toString() == attempt.answer,
                          orElse: () => OptionModel(
                              id: 0, option: "Not answered", isCorrect: false),
                        );

                  final correctOption = isType1 || isType3
                      ? null
                      : question?.options?.firstWhere(
                          (option) => option.isCorrect,
                          orElse: () => OptionModel(
                              id: 0,
                              option: "No correct answer",
                              isCorrect: false),
                        );

                  final isCorrect =
                      isType1 || isType3 ? null : selectedOption?.isCorrect;
                  final formattedTime = DateFormat('MMM dd, yyyy - hh:mm a')
                      .format(DateTime.parse(attempt.submissionTime));

                  // For shuffle questions, split the answer back into lines
                  final userAnswerLines = isType3
                      ? attempt.answer
                          .replaceAll(r'\\n', '\n')
                          .replaceAll(r'\n', '\n')
                          .split('\n')
                      : [];
                  final correctAnswerLines = isType3
                      ? question?.text
                          ?.replaceAll(r'\\n', '\n')
                          .replaceAll(r'\n', '\n')
                          .split('\n')
                      : [];

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 15),
                    curve: Curves.easeInOut,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      isType3
                                          ? (question?.output?.output ??
                                              'Arrange the code in correct order')
                                          : (question?.text ??
                                              'No question text'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              if (isType1) ...[
                                // Display for sentence-type questions (type 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.short_text_rounded,
                                        color: Colors.blue[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Answer',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  attempt.answer.isNotEmpty
                                      ? attempt.answer
                                      : "No answer provided",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Score: ${attempt.score}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ] else if (isType3) ...[
                                // Display for shuffle-type questions (type 3)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: attempt.score > 0
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: attempt.score > 0
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        attempt.score > 0
                                            ? Icons.check
                                            : Icons.close,
                                        color: attempt.score > 0
                                            ? Colors.green[600]
                                            : Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        attempt.score > 0
                                            ? 'Correct'
                                            : 'Incorrect',
                                        style: TextStyle(
                                          color: attempt.score > 0
                                              ? Colors.green[600]
                                              : Colors.red[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Score: ${attempt.score}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Your arrangement
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your arrangement:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      for (final line in userAnswerLines)
                                        if (line.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.reorder,
                                                  color: Colors.amber,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    line,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Correct arrangement
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.green.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Correct arrangement:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      for (final line
                                          in correctAnswerLines ?? [])
                                        if (line.trim().isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    line,
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                              ]
                              // else if (isType3) ...[
                              //   // Display for shuffle-type questions (type 3)
                              //   Column(
                              //     children: [
                              //       // Score status container (unchanged)
                              //       Container(
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 12, vertical: 8),
                              //         decoration: BoxDecoration(
                              //           color: attempt.score > 0
                              //               ? Colors.green.withOpacity(0.1)
                              //               : Colors.red.withOpacity(0.1),
                              //           borderRadius: BorderRadius.circular(8),
                              //           border: Border.all(
                              //             color: attempt.score > 0
                              //                 ? Colors.green.withOpacity(0.3)
                              //                 : Colors.red.withOpacity(0.3),
                              //             width: 1,
                              //           ),
                              //         ),
                              //         child: Row(
                              //           children: [
                              //             Icon(
                              //               attempt.score > 0
                              //                   ? Icons.check
                              //                   : Icons.close,
                              //               color: attempt.score > 0
                              //                   ? Colors.green[600]
                              //                   : Colors.red[600],
                              //               size: 20,
                              //             ),
                              //             const SizedBox(width: 8),
                              //             Text(
                              //               attempt.score > 0
                              //                   ? 'Correct'
                              //                   : 'Incorrect',
                              //               style: TextStyle(
                              //                 color: attempt.score > 0
                              //                     ? Colors.green[600]
                              //                     : Colors.red[600],
                              //                 fontWeight: FontWeight.bold,
                              //                 fontSize: 15,
                              //               ),
                              //             ),
                              //             const Spacer(),
                              //             Container(
                              //               padding: const EdgeInsets.symmetric(
                              //                   horizontal: 10, vertical: 4),
                              //               decoration: BoxDecoration(
                              //                 color:
                              //                     Colors.amber.withOpacity(0.2),
                              //                 borderRadius:
                              //                     BorderRadius.circular(12),
                              //               ),
                              //               child: Text(
                              //                 'Score: ${attempt.score}',
                              //                 style: const TextStyle(
                              //                   fontWeight: FontWeight.bold,
                              //                   fontSize: 14,
                              //                 ),
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //       const SizedBox(height: 16),
                              //
                              //       // Line-by-line comparison
                              //       Builder(
                              //         builder: (_) {
                              //           // Function to filter out empty lines and normalize
                              //           List<String> processLines(
                              //               List<dynamic> lines) {
                              //             return lines
                              //                 .where((line) => line
                              //                     .toString()
                              //                     .trim()
                              //                     .isNotEmpty)
                              //                 .map((line) =>
                              //                     line.toString().trim())
                              //                 .toList();
                              //           }
                              //
                              //           // Process both answer sets (remove empty lines)
                              //           List<String> userNonEmptyLines =
                              //               processLines(userAnswerLines
                              //                   .cast<dynamic>());
                              //           List<String> correctNonEmptyLines =
                              //               processLines(
                              //                   (correctAnswerLines ?? [])
                              //                       .cast<dynamic>());
                              //
                              //           // Count matching lines (position-sensitive)
                              //           int correctLines = 0;
                              //           int minLength = min(
                              //               userNonEmptyLines.length,
                              //               correctNonEmptyLines.length);
                              //
                              //           // Track matches
                              //           List<bool> matches = [];
                              //           for (int i = 0; i < minLength; i++) {
                              //             bool match = userNonEmptyLines[i] ==
                              //                 correctNonEmptyLines[i];
                              //             if (match) correctLines++;
                              //             matches.add(match);
                              //           }
                              //
                              //           return Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               // Your arrangement (non-empty lines only)
                              //               Container(
                              //                 padding: const EdgeInsets.all(12),
                              //                 decoration: BoxDecoration(
                              //                   color: Colors.grey[800],
                              //                   borderRadius:
                              //                       BorderRadius.circular(8),
                              //                 ),
                              //                 child: Column(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.start,
                              //                   children: [
                              //                     Text(
                              //                       'Your arrangement:',
                              //                       style: TextStyle(
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                         color: Colors.grey[400],
                              //                       ),
                              //                     ),
                              //                     const SizedBox(height: 8),
                              //                     Text(
                              //                       'Correct: $correctLines, Incorrect: ${userNonEmptyLines.length - correctLines}',
                              //                       style: const TextStyle(
                              //                         color: Colors.white70,
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                       ),
                              //                     ),
                              //                     const SizedBox(height: 8),
                              //
                              //                     // Display non-empty user lines with indicators
                              //                     for (int i = 0;
                              //                         i <
                              //                             userNonEmptyLines
                              //                                 .length;
                              //                         i++)
                              //                       Padding(
                              //                         padding: const EdgeInsets
                              //                             .symmetric(
                              //                             vertical: 4),
                              //                         child: Row(
                              //                           crossAxisAlignment:
                              //                               CrossAxisAlignment
                              //                                   .start,
                              //                           children: [
                              //                             Icon(
                              //                               i < correctNonEmptyLines.length &&
                              //                                       matches[i]
                              //                                   ? Icons
                              //                                       .check_circle
                              //                                   : Icons.cancel,
                              //                               color: i <
                              //                                           correctNonEmptyLines
                              //                                               .length &&
                              //                                       matches[i]
                              //                                   ? Colors.green
                              //                                   : Colors.red,
                              //                               size: 20,
                              //                             ),
                              //                             const SizedBox(
                              //                                 width: 8),
                              //                             Expanded(
                              //                               child: Column(
                              //                                 crossAxisAlignment:
                              //                                     CrossAxisAlignment
                              //                                         .start,
                              //                                 children: [
                              //                                   Text(
                              //                                     userNonEmptyLines[
                              //                                         i],
                              //                                     style: const TextStyle(
                              //                                         color: Colors
                              //                                             .white),
                              //                                   ),
                              //                                   if (i <
                              //                                           correctNonEmptyLines
                              //                                               .length &&
                              //                                       !matches[i])
                              //                                     Text(
                              //                                       'Expected: ${correctNonEmptyLines[i]}',
                              //                                       style:
                              //                                           TextStyle(
                              //                                         color: Colors
                              //                                                 .green[
                              //                                             300],
                              //                                         fontSize:
                              //                                             12,
                              //                                       ),
                              //                                     ),
                              //                                 ],
                              //                               ),
                              //                             ),
                              //                           ],
                              //                         ),
                              //                       ),
                              //                   ],
                              //                 ),
                              //               ),
                              //               const SizedBox(height: 12),
                              //
                              //               // Correct arrangement (non-empty lines only)
                              //               Container(
                              //                 padding: const EdgeInsets.all(12),
                              //                 decoration: BoxDecoration(
                              //                   color: Colors.grey[800],
                              //                   borderRadius:
                              //                       BorderRadius.circular(8),
                              //                   border: Border.all(
                              //                     color: Colors.green
                              //                         .withOpacity(0.5),
                              //                   ),
                              //                 ),
                              //                 child: Column(
                              //                   crossAxisAlignment:
                              //                       CrossAxisAlignment.start,
                              //                   children: [
                              //                     Text(
                              //                       'Correct arrangement:',
                              //                       style: TextStyle(
                              //                         fontWeight:
                              //                             FontWeight.bold,
                              //                         color: Colors.grey[400],
                              //                       ),
                              //                     ),
                              //                     const SizedBox(height: 8),
                              //                     for (int i = 0;
                              //                         i <
                              //                             correctNonEmptyLines
                              //                                 .length;
                              //                         i++)
                              //                       Padding(
                              //                         padding: const EdgeInsets
                              //                             .symmetric(
                              //                             vertical: 4),
                              //                         child: Row(
                              //                           crossAxisAlignment:
                              //                               CrossAxisAlignment
                              //                                   .start,
                              //                           children: [
                              //                             const Icon(
                              //                               Icons.check_circle,
                              //                               color: Colors.green,
                              //                               size: 20,
                              //                             ),
                              //                             const SizedBox(
                              //                                 width: 8),
                              //                             Expanded(
                              //                               child: Text(
                              //                                 correctNonEmptyLines[
                              //                                     i],
                              //                                 style: const TextStyle(
                              //                                     color: Colors
                              //                                         .white),
                              //                               ),
                              //                             ),
                              //                           ],
                              //                         ),
                              //                       ),
                              //                   ],
                              //                 ),
                              //               ),
                              //             ],
                              //           );
                              //         },
                              //       ),
                              //     ],
                              //   ),
                              // ]
                              else ...[
                                // Display for multiple-choice questions
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (isCorrect ?? false)
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (isCorrect ?? false)
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        (isCorrect ?? false)
                                            ? Icons.check
                                            : Icons.close,
                                        color: (isCorrect ?? false)
                                            ? Colors.green[600]
                                            : Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        (isCorrect ?? false)
                                            ? 'Correct'
                                            : 'Incorrect',
                                        style: TextStyle(
                                          color: (isCorrect ?? false)
                                              ? Colors.green[600]
                                              : Colors.red[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Score: ${attempt.score}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildAnswerRow(
                                  title: 'Your answer:',
                                  answer:
                                      selectedOption?.option ?? "Not answered",
                                  isCorrect: isCorrect ?? false,
                                ),
                                if (!(isCorrect ?? false)) ...[
                                  const SizedBox(height: 8),
                                  _buildAnswerRow(
                                    title: 'Correct answer:',
                                    answer: correctOption?.option ??
                                        "No correct answer",
                                    isCorrect: true,
                                  ),
                                ],
                              ],
                              const SizedBox(height: 12),
                              Divider(
                                color: Colors.grey[300],
                                height: 1,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerRow({
    required String title,
    required String answer,
    required bool isCorrect,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: isCorrect ? Colors.green[600] : Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:digital_shores/app/presentation/provider/i_finance_notifier.dart';
import 'package:digital_shores/app/presentation/widgets/input/date_input_column.dart';
import 'package:digital_shores/app/presentation/widgets/input/text_input_column.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/enums.dart';
import 'package:digital_shores/core/utils/parse_finance_category.dart';
import 'package:flutter/material.dart';

class FinanceForm extends StatelessWidget {
  const FinanceForm({
    super.key,
    required this.notifier,
  });

  final IFinanceNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Form(
      key: notifier.formKey,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: notifier.financeCategoryController,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: kTitle6TextStyle,
                  ),
                  const SizedBox(height: 8),
                  ...FinanceLogCategory.values.map(
                    (category) {
                      return GestureDetector(
                        onTap: () => notifier.setCategory(category),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: value == category ? color.primary : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ParseFinanceCategory.toText(category),
                                style: kBodyTextStyle,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          DateInputColumn(
            text: 'Tanggal',
            hintText: 'Pilih tanggal',
            notifier: notifier.dateController,
            formKey: notifier.formKey,
            autoHour: true,
            limitLastDateToToday: true,
            validator: (value) => value == null,
            validatorText: 'Tanggal tidak boleh kosong',
          ),
          TextInputColumn(
            text: 'Deskripsi',
            controller: notifier.descriptionController,
            formKey: notifier.formKey,
            hintText: 'Masukkan barang atau jasa yang dibeli',
            validator: (value) => value.isEmpty,
            validatorText: 'Jumlah uang tidak boleh kosong',
          ),
          TextInputColumn(
            text: 'Jumlah',
            controller: notifier.amountController,
            formKey: notifier.formKey,
            // number: true,
            hintText: 'Masukkan jumlah uang yang digunakan',
            validator: (value) => value.isEmpty,
            validatorText: 'Jumlah uang tidak boleh kosong',
            isLastInput: true,
            currency: true,
            onComplete: notifier.addData,
          ),
        ],
      ),
    );
  }
}

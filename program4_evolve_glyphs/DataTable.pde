import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Collections;

class DataTable {

  String[] columsNames = null; // names of the columns
  boolean[] colContainsNumbers = null; // whether each column ontains number (or text)
  ArrayList<Object[]> dataRows = new ArrayList<Object[]>(); // rows with original values
  ArrayList<float[]> dataRowsNormalised = new ArrayList<float[]>(); // rows with normalised values

  DataTable(String pathInputCSVFile, int[] arrayIndexesColsToLoad) {

    // Create list with the indexes of the columns to load
    ArrayList<Integer> indexesColsToLoad = new ArrayList<>();
    if (arrayIndexesColsToLoad != null) {
      for (int i : arrayIndexesColsToLoad) {
        indexesColsToLoad.add(i);
      }
    }

    // Attempt to read input CSV file
    try {
      BufferedReader br = new BufferedReader(new FileReader(pathInputCSVFile));

      // Read line by line
      String line;
      int numColsToLoad = -1;
      while ((line = br.readLine()) != null) {

        // Split values in each table row
        String[] values = line.split(Character.toString(';'));

        // Determine number of columns to load
        if (numColsToLoad == -1) {
          numColsToLoad = indexesColsToLoad.size() > 0 ? indexesColsToLoad.size() : values.length;
        }

        // Create array with only the values of the columns that should be loaded
        String[] valuesFiltered = new String[numColsToLoad];
        int currCol = 0;
        for (int v = 0; v < values.length; v++) {
          if (indexesColsToLoad.isEmpty() || indexesColsToLoad.contains(v)) {
            valuesFiltered[currCol] = values[v].trim();
            currCol++;
          }
        }

        // Get names of columns if first line and continue to next data row
        if (columsNames == null) {
          columsNames = new String[numColsToLoad];
          System.arraycopy(valuesFiltered, 0, columsNames, 0, valuesFiltered.length);
          continue;
        }

        // Determine what each column contains (text or numbers)
        if (colContainsNumbers == null) {
          colContainsNumbers = new boolean[numColsToLoad];
          for (int col = 0; col < getNumColumns(); col++) {
            try {
              Float.parseFloat(valuesFiltered[col]);
              colContainsNumbers[col] = true;
            }
            catch (NumberFormatException e) {
              colContainsNumbers[col] = false;
            }
          }
        }

        // Add new data row with numbers parsed to floats
        Object[] newDataRow = new Object[numColsToLoad];
        System.arraycopy(valuesFiltered, 0, newDataRow, 0, valuesFiltered.length);
        for (int col = 0; col < getNumColumns(); col++) {
          if (colContainsNumbers[col]) {
            newDataRow[col] = Float.parseFloat((String) newDataRow[col]);
          }
        }
        dataRows.add(newDataRow);
      }
      br.close();
    }
    catch (IOException e) {
      e.printStackTrace();
    }

    // Create list of arrays to store normalised values
    for (int row = 0; row < getNumRows(); row++) {
      dataRowsNormalised.add(new float[getNumColumns()]);
    }

    // Convert each value in a normalised version (including text values)
    for (int col = 0; col < getNumColumns(); col++) {

      if (colContainsNumbers[col]) { // If current column contains numbers

        // Find minimum and maximum values found in current column
        float minValue = Float.POSITIVE_INFINITY;
        float maxValue = Float.NEGATIVE_INFINITY;
        for (int row = 0; row < getNumRows(); row++) {
          float currValue = (float) dataRows.get(row)[col];
          minValue = min(minValue, currValue);
          maxValue = max(maxValue, currValue);
        }
        println("Column: " + columsNames[col] + " [" + minValue + ", " + maxValue + "]");

        // Create row with normalised values
        for (int row = 0; row < getNumRows(); row++) {
          float currValue = (float) dataRows.get(row)[col];
          if (minValue < maxValue) {
            dataRowsNormalised.get(row)[col] = map(currValue, minValue, maxValue, 0, 1);
          } else {
            dataRowsNormalised.get(row)[col] = 0;
          }
        }
      } else { // If current column contains text

        // Create list with unique text values found in current column sorted alphabetically
        ArrayList<String> uniqueValues = new ArrayList<String>();
        for (int row = 0; row < getNumRows(); row++) {
          String currValue = ((String) dataRows.get(row)[col]).toLowerCase();
          if (!uniqueValues.contains(currValue)) {
            uniqueValues.add(currValue);
          }
        }
        Collections.sort(uniqueValues);
        println("Column: " + columsNames[col] + " [" + uniqueValues.size() + " unique strings]");


        // Create row with normalised values (normalised indexes)
        for (int row = 0; row < getNumRows(); row++) {
          String currValue = ((String) dataRows.get(row)[col]).toLowerCase();
          dataRowsNormalised.get(row)[col] = uniqueValues.indexOf(currValue) / (float) (uniqueValues.size() - 1);
        }
      }
    }

    println("Data cols loaded: " + getNumColumns());
    println("Data rows loaded: " + getNumRows());
  }

  /**
   * Returns original value as string.
   */
  String getValue(int row, int col) {
    if (colContainsNumbers[col]) {
      float number = (Float) dataRows.get(row)[col];
      if (number == (int) number) {
        return ((int) number) + "";
      }
    }
    return dataRows.get(row)[col].toString();
  }

  /**
   * Returns normalised value.
   */
  float getValueNorm(int row, int col) {
    return dataRowsNormalised.get(row)[col];
  }

  /**
   * Returns the number of columns.
   */
  int getNumColumns() {
    return columsNames.length;
  }

  /**
   * Returns the number of rows.
   */
  int getNumRows() {
    return dataRows.size();
  }

  /**
   * Returns the name of a column.
   */
  String getColumnName(int col) {
    return columsNames[col];
  }

  void saveToCSV(String pathOutputCSVFile) {
    Table table = new Table();
    for (int col = 0; col < getNumColumns(); col++) {
      table.addColumn(columsNames[col]);
    }
    for (int row = 0; row < getNumRows(); row++) {
      TableRow newRow = table.addRow();
      for (int col = 0; col < getNumColumns(); col++) {
        newRow.setFloat(columsNames[col], getValueNorm(row, col));
      }
    }
    saveTable(table, pathOutputCSVFile);
  }
}

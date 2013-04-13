package br.cin.ufpe.features.total;

import java.awt.GridBagConstraints;
import java.awt.event.KeyListener;

import javax.swing.JLabel;
import javax.swing.JTextField;

import org.softlang.company.Company;
import org.softlang.company.Department;
import org.softlang.company.Employee;
import org.softlang.swing.model.Model;
import org.softlang.swing.view.AbstractView;
import org.softlang.swing.view.CompanyView;
import org.softlang.swing.view.DepartmentView;
import org.softlang.swing.view.EmployeeView;

public privileged aspect TotalFeature {

	pointcut newAbstractView(AbstractView cthis) : execution(AbstractView.new(..)) && this(cthis);

	void around(AbstractView cthis) : newAbstractView(cthis) {
		proceed(cthis);
		cthis.total = new JTextField();
	}
	
	pointcut addSalaryListener(EmployeeView cthis, KeyListener listener) 
		: execution(* EmployeeView.addSalaryListener(..)) && this(cthis) && args(listener);

	before(EmployeeView cthis, KeyListener listener) : addSalaryListener(cthis, listener) {
		cthis.total.addKeyListener(listener);
	}

	pointcut createCompanyViewTotal(CompanyView cthis) 
		: call(* CompanyView.name(..)) && this(cthis) 
		&& withincode(private void CompanyView.createView(..));

	after(CompanyView cthis) returning() : createCompanyViewTotal(cthis) {
		createViewTotal(cthis.c);
		cthis.add(new JLabel("Total: "), cthis.c);
		createTotal(cthis.c, cthis.total, cthis.model);
		cthis.add(cthis.total, cthis.c);
	}

	pointcut createDepartmentViewTotal(DepartmentView cthis) 
		: call(* DepartmentView.name(..)) && this(cthis)
		&& withincode(private void DepartmentView.createView(..));

	after(DepartmentView cthis) returning() : createDepartmentViewTotal(cthis) {
		createViewTotal(cthis.c);
		cthis.add(new JLabel("Total: "), cthis.c);
		createTotal(cthis.c, cthis.total, cthis.model);
		cthis.add(cthis.total, cthis.c);
	}
	
	pointcut createEmployeeViewTotal(EmployeeView cthis) 
		: call(* EmployeeView.salary(..)) && this(cthis)
		&& withincode(private void EmployeeView.createView(..));

	after(EmployeeView cthis) returning() : createEmployeeViewTotal(cthis) {
		cthis.c.gridx = 1;
		cthis.c.fill = GridBagConstraints.HORIZONTAL;
		cthis.c.weightx = 1;
		cthis.total.setText(cthis.model.getTotal());
		cthis.add(cthis.total, cthis.c);
	}

	private void createViewTotal(GridBagConstraints c) {
		// total
		c.gridy = 1;
		c.gridx = 0;
		c.weightx = 0;
		c.fill = GridBagConstraints.NONE;
	}

	private void createTotal(GridBagConstraints c, JTextField total,
			Model model) {
		c.gridx = 1;
		c.weightx = 1;
		c.fill = GridBagConstraints.HORIZONTAL;
		total.setText(model.getTotal());
		total.setEditable(false);
	}

	/**
	 * This method returns the total value for the current company, department
	 * or employee.
	 * 
	 * @return current total value
	 */
	public String Model.getTotal() {
		if (currentValue != null) {
			if (currentValue.isCompany()) {
				return Double.toString(Total.total((Company) currentValue));
			} else if (currentValue.isDepartment()) {
				return Double.toString(Total.total((Department) currentValue));
			} else if (currentValue.isEmployee()) {
				return Double.toString(Total.total((Employee) currentValue));
			} else {
				return "0";
			}
		} else {
			return "0";
		}
	}

	private JTextField AbstractView.total;

	// Interesting interaction between Total and Cut
	/**
	 * This method refreshs the total value after a cut.
	 */
	public void AbstractView.refresh() {
		total.setText(model.getTotal());
	}
}

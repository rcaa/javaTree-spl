package br.cin.ufpe.features.cut;

import java.awt.GridBagConstraints;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.lang.reflect.Field;

import javax.swing.JButton;

import org.softlang.company.Company;
import org.softlang.company.Department;
import org.softlang.company.Employee;
import org.softlang.swing.controller.Controller;
import org.softlang.swing.model.Model;
import org.softlang.swing.view.AbstractView;
import org.softlang.swing.view.CompanyView;
import org.softlang.swing.view.DepartmentView;
import org.softlang.swing.view.EmployeeView;
import org.softlang.swing.view.MainView;

public privileged aspect CutFeature {

	pointcut newAbstractView(AbstractView cthis) : execution(AbstractView.new(..)) && this(cthis);

	after(AbstractView cthis) returning() : newAbstractView(cthis) {
		cthis.cut = new JButton("cut");
	}

	pointcut addCutListenerComanyView(
			org.softlang.swing.controller.Controller.CompaniesTreeListener ctl) 
		: call(*View.new(..)) && this(ctl)
		&& withincode(public void org.softlang.swing.controller.Controller.CompaniesTreeListener.valueChanged(..));

	after(org.softlang.swing.controller.Controller.CompaniesTreeListener ctl) returning(Object obj) 
		: addCutListenerComanyView(ctl) {
		try {
			Field field = org.softlang.swing.controller.Controller.CompaniesTreeListener.class
					.getDeclaredField("this$0");
			field.setAccessible(true);
			Controller outer = (Controller) field.get(ctl);
			if (obj instanceof CompanyView) {
				((CompanyView)obj).addCutListener(new CutListener(outer));
			} else if (obj instanceof DepartmentView) {
				((DepartmentView)obj).addCutListener(new CutListener(outer));
			} else if (obj instanceof EmployeeView) {
				((EmployeeView)obj).addCutListener(new CutListener(outer));
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	pointcut createCompanyViewCut(CompanyView cthis) 
		: call(* CompanyView.filler(..)) && this(cthis) 
		&& withincode(private void CompanyView.createView(..));

	before(CompanyView cthis) : createCompanyViewCut(cthis) {
		createViewCut(cthis.c, 2);
		cthis.add(cthis.cut, cthis.c);
	}

	pointcut createDepartmentViewCut(DepartmentView cthis) 
		: call(* DepartmentView.filler(..)) && this(cthis) 
		&& withincode(private void DepartmentView.createView(..));

	before(DepartmentView cthis) : createDepartmentViewCut(cthis) {
		createViewCut(cthis.c, 2);
		cthis.add(cthis.cut, cthis.c);
	}

	pointcut createEmployeeViewCut(EmployeeView cthis) 
		: call(* EmployeeView.filler(..)) && this(cthis) 
		&& withincode(private void EmployeeView.createView(..));

	before(EmployeeView cthis) : createEmployeeViewCut(cthis) {
		createViewCut(cthis.c, 3);
		cthis.add(cthis.cut, cthis.c);
	}

	private void createViewCut(GridBagConstraints c, int gridy) {
		c.gridy = gridy;
		c.gridx = 0;
		c.gridwidth = 2;
		c.weightx = 0;
		c.fill = GridBagConstraints.NONE;
		c.anchor = GridBagConstraints.CENTER;
	}

	public JButton AbstractView.cut;

	/**
	 * This method cuts the current company, department or employee.
	 */
	public void Model.cut() {
		if (currentValue != null) {
			if (currentValue.isCompany()) {
				Cut.cut((Company) currentValue);
			} else if (currentValue.isDepartment()) {
				Cut.cut((Department) currentValue);
			} else if (currentValue.isEmployee()) {
				Cut.cut((Employee) currentValue);
			}
		}
	}

	/**
	 * This method adds the listener for the cut button of the current view.
	 * 
	 * @param cut
	 *            listener
	 */
	public void AbstractView.addCutListener(ActionListener listener) {
		cut.addActionListener(listener);
	}

	/**
	 * refresh GUI for cut operation
	 */
	public void MainView.refresh() {
		((AbstractView)currentView).refresh();
	}

	private class CutListener implements ActionListener {

		private Controller c;

		public CutListener(Controller c) {
			this.c = c;
		}

		@Override
		public void actionPerformed(ActionEvent e) {
			c.getModel().cut();
			c.getView().refresh();
		}
	}
}

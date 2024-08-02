import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="entry-form"
export default class extends Controller {
  static targets = ["creditTitle", "debitTitle", "amount", "postBtn", "table"];

  connect() {
    this.postBtnTarget.disabled = true;
  }

  validate = (event) => {
    const targetElement = event.target;
    const validationResult = this.#handleValidation(targetElement);
    this.#updateForm(targetElement, validationResult);
  };

  post = async (event) => {
    event.preventDefault();

    if (this.#isAllValid()) {
      const formData = new FormData();
      const appendData = {
        "journal_entry[credit_title]": this.creditTitleTarget.value,
        "journal_entry[debit_title]": this.debitTitleTarget.value,
        "journal_entry[amount]": this.amountTarget.value,
        csrfToken: document.querySelector("meta[name=csrf-token]").content,
      };

      const formattedFormData = this.#formatFormData(formData, appendData);

      // form要素のaction属性にurlが指定されている
      const url = event.target.action;
      const method = event.target.method;
      await this.#postFormData(url, method, formattedFormData);
    } else {
      this.#validatesAll();
    }
  };

  delete = async (event) => {
    event.preventDefault();

    const url = event.target.action;
    const method = "DELETE";

    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")
            .content,
          Accept: "application/json",
        },
      });

      if (!response.ok) {
        const responseJson = await response.json();
        this.#updateTable(responseJson.table);
        this.#showToast(responseJson.toast);
      } else {
        const responseJson = await response.json();
        this.#updateTable(responseJson.table);
        this.#showToast(responseJson.toast);
      }
    } catch (error) {
      console.error(error.message);
    }
  };

  #formatFormData = (formData, appendData) => {
    for (const key in appendData) {
      formData.append(key, appendData[key]);
    }

    return formData;
  };

  #postFormData = async (url, method, formData) => {
    try {
      const response = await fetch(url, {
        method: method,
        headers: {
          "X-CSRF-Token": formData.get("csrfToken"),
          Accept: "application/json",
        },
        body: formData,
      });

      if (!response.ok) {
        const responseJson = await response.json();
        this.#updateTable(responseJson.table);
        this.#showToast(responseJson.toast);
      }

      const responseJson = await response.json();
      this.#updateTable(responseJson.table);
      this.#showToast(responseJson.toast);
    } catch (error) {
      console.error(error.message);
    }
  };

  #validatesAll = () => {
    const elements = [
      this.creditTitleTarget,
      this.debitTitleTarget,
      this.amountTarget,
    ];
    elements.forEach((element) => {
      const validationResult = this.#handleValidation(element);
      this.#updateForm(element, validationResult);
    });
  };

  #handleValidation = (element) => {
    // 入力フォームの一つ前の要素はラベル
    const labelText = element.previousElementSibling.innerText;
    const isInteger = element === this.amountTarget;
    return this.#validates({ value: element.value, labelText, isInteger });
  };

  #validates = ({ value, labelText, isInteger = false }) => {
    // 最小文字数
    if (value.length <= 0) {
      return { valid: false, message: `${labelText}を入力してください` };
    }

    // 最大文字数
    const maxLength = isInteger ? 9 : 20;
    const length = new Blob([value]).size;

    if (length > maxLength) {
      const message = isInteger
        ? `${labelText}は${maxLength}桁以内で入力してください`
        : `${labelText}は全角${maxLength / 2}文字以内で入力してください`;

      return { valid: false, message: message };
    }

    // 正の整数
    if (isInteger && Math.sign(value) === -1) {
      return {
        valid: false,
        message: `${labelText}は正の値を入力してください`,
      };
    }

    return { valid: true, message: "" };
  };

  #isAllValid = () => {
    const validationResults = [
      this.#handleValidation(this.creditTitleTarget),
      this.#handleValidation(this.debitTitleTarget),
      this.#handleValidation(this.amountTarget),
    ];

    return validationResults.every((result) => result.valid);
  };

  #updateForm = (element, validationResult) => {
    const errorContainer = element.nextElementSibling;
    errorContainer.innerText = validationResult.message;

    // toggle(token, force)のforceにboolを渡すと、追加、削除を制御できる
    element.classList.toggle("hp_invalid__border", !validationResult.valid);

    const label = element.previousElementSibling;
    label.classList.toggle("hp_invalid__text", !validationResult.valid);

    this.postBtnTarget.disabled = !this.#isAllValid();
  };

  #updateTable = (html) => {
    this.tableTarget.innerHTML = html;
  };

  #showToast = (html) => {
    document.getElementById("toast")?.remove();

    const element = document.createElement("div");
    element.setAttribute("id", "toast");
    element.innerHTML = html;
    document.body.appendChild(element);
  };
}
